package cn.qihangerp.sse;

import cn.qihangerp.enums.EnumShopType;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

@Slf4j
@Service
public class SseService {

    private static final long SSE_TIMEOUT = 1800000L; // 30 minutes timeout
    private final AtomicLong counter = new AtomicLong(0); // 用于生成唯一的 emitter ID

    // 线程安全的列表存储所有活跃的 SseEmitter
//    private final List<SseEmitterWithId> emitters = new CopyOnWriteArrayList<>();
    // 使用线程安全的 ConcurrentHashMap 来存储 clientId -> SseEmitter 的映射
    private final ConcurrentHashMap<String, SseEmitter> clientEmitters = new ConcurrentHashMap<>();

    /**
     * 为指定的 clientId 创建或替换 SSE 连接
     * 如果该 clientId 已存在连接，旧的会被关闭并替换。
     *
     * @param clientId 客户端唯一标识符
     * @return 新创建的 SseEmitter 实例
     */
    public SseEmitter createConnection(String clientId) {

        // 1. (可选) 检查是否已有连接
        SseEmitter existingEmitter = clientEmitters.get(clientId);
        if (existingEmitter != null) {
            log.info("正在替换客户端 ID: {} 的现有活动连接", clientId);
            // 可以选择先完成旧的连接
            existingEmitter.complete();
        }

        // 2. 创建新的 SseEmitter，设置较长的超时时间 (例如 30 分钟)
        SseEmitter emitter = new SseEmitter(TimeUnit.MINUTES.toMillis(30));

        // 3. 注册 SseEmitter 的生命周期回调，以便在连接关闭、超时或出错时自动清理
        emitter.onCompletion(() -> {
            clientEmitters.remove(clientId);
            log.debug("客户端 ID: {} 的 SSE 连接已完成", clientId);
        });

        emitter.onTimeout(() -> {
            clientEmitters.remove(clientId);
            log.info("客户端 ID: {} 的 SSE 连接已超时", clientId);
        });

        emitter.onError((Throwable throwable) -> {
            clientEmitters.remove(clientId);
            if (throwable instanceof org.springframework.web.context.request.async.AsyncRequestNotUsableException) {
                log.debug("客户端 ID: {} 的 SSE 连接断开（客户端主动断开或网络中断）", clientId);
            } else {
                log.warn("客户端 ID: {} 的 SSE 连接发生错误", clientId, throwable);
            }
        });

        // 4. 将新的 emitter 存入 map
        clientEmitters.put(clientId, emitter);
        log.info("已为客户端 ID: {} 创建并存储新的 SSE 连接", clientId);

        return emitter;
    }

//    /**
//     * 创建并返回一个新的 SseEmitter
//     * @return SseEmitter
//     */
//    public SseEmitter createEmitter() {
//        long id = counter.incrementAndGet();
//        SseEmitter emitter = new SseEmitter(SSE_TIMEOUT);
//
//        SseEmitterWithId emitterWithId = new SseEmitterWithId(emitter, id);
//        emitters.add(emitterWithId);
//        log.info("SSE建立新连接. Total: {}. Emitter ID: {}", emitters.size(), id);
//
//        // 添加完成回调，当连接断开时自动移除
//        emitter.onCompletion(() -> {
//            emitters.remove(emitterWithId);
//        });
//
//        // 添加超时回调
//        emitter.onTimeout(() -> {
//            emitters.remove(emitterWithId);
//            log.info("SSE连接超时. Total: {}. Removed Emitter ID: {}", emitters.size(), id);
//            emitter.complete();
//        });
//
//        // 添加错误回调
//        emitter.onError((Throwable throwable) -> {
//            emitters.remove(emitterWithId);
//            log.warn("SSE连接错误. Total: {}. Removed Emitter ID: {}. Error: {}", emitters.size(), id, throwable.getMessage());
//            emitter.complete();
//        });
//
//        // 发送初始连接确认消息 (可选)
////        try {
////            emitter.send(SseEmitter.event().name("CONNECT").data("Connected to SSE"));
////        } catch (IOException e) {
////            logger.error("Failed to send initial connect message to emitter ID: {}", id, e);
////            emitters.remove(emitterWithId);
////            emitter.completeWithError(e);
////        }
//
//        return emitter;
//    }

    /**
     * 向指定 clientId 的客户端发送消息
     *
     * @param clientId  目标客户端 ID
     * @param eventName 事件名称 (例如 "newOrder")
     * @param data      消息数据
     * @return 是否成功发送 (true 表示发送成功或放入队列，false 表示客户端不存在或连接已断开)
     */
    public boolean sendMessageToClient(String clientId, String eventName, Object data) {
        SseEmitter emitter = clientEmitters.get(clientId);

        // 检查 emitter 是否存在且未完成 (未超时、未出错、未主动关闭)
        if (emitter != null) {
            try {
                // 发送事件
                emitter.send(SseEmitter.event().name(eventName).data(data));
                log.debug("消息已发送至客户端 ID: {} (事件: {}, 数据: {})", clientId, eventName, data);
                return true; // 发送成功
            } catch (IOException e) {
                // 发送出错，通常意味着连接已断开
                log.debug("无法向客户端 ID: {} 发送消息，正在移除连接", clientId, e);
                // 移除失效的 emitter
                clientEmitters.remove(clientId);
                // 标记 emitter 完成并带有错误
                emitter.completeWithError(e);
                return false; // 发送失败
            }
        } else {
            // 客户端不存在或连接已完成
            log.info("尝试向不存在或已完成的客户端 ID: {} 发送消息", clientId);
            return false;
        }
    }

    /**
     * (可选) 移除指定 clientId 的连接
     *
     * @param clientId 要移除的客户端 ID
     */
    public void removeConnection(String clientId) {
        SseEmitter removed = clientEmitters.remove(clientId);
        if (removed != null) {
            removed.complete(); // 确保 emitter 被完成
            log.info("手动移除了客户端 ID: {} 的 SSE 连接", clientId);
        }
    }
    public int broadcastNewOrderMessage(EnumShopType shopType,String orderNum){
        return broadcastMessage("NewOrder", Map.of("shopType" , shopType.getName(), "orderNum", orderNum));
    }

    /**
     * 【新增】向所有已连接的客户端广播消息
     *
     * @param eventName 事件名称 (例如 "broadcastAnnouncement")
     * @param data      消息数据
     * @return 成功发送消息的客户端数量
     */
    public int broadcastMessage(String eventName, Object data) {
        log.info("开始向所有客户端广播消息 (事件: {}, 数据: {})", eventName, data);
        int successCount = 0;

        // 创建当前客户端列表的副本以避免并发修改异常
        List<String> clientIdsSnapshot = new ArrayList<>(clientEmitters.keySet());

        for (String clientId : clientIdsSnapshot) {
            boolean sent = sendMessageToClient(clientId, eventName, data); // 复用单发逻辑
            if (sent) {
                successCount++;
            }
        }

        log.info("广播完成。成功发送给 {} 个客户端。", successCount);
        return successCount;
    }

    /**
     * 定时向所有客户端发送心跳消息
     * 每 30 秒执行一次
     */
    @Scheduled(fixedRate = 30000) // 30秒发送一次心跳
    public void sendHeartbeats() {
        List<String> clientIdsSnapshot = new ArrayList<>(clientEmitters.keySet());
//        log.info("发送心跳： {} clients", clientIdsSnapshot.size());
        for (String clientId : clientIdsSnapshot) {
            // 使用一个特殊的事件名，如 "heartbeat"
            if (!sendMessageToClient(clientId, "heartbeat", System.currentTimeMillis())) {
                log.debug("心跳发送失败 {}", clientId);
                // sendMessageToClient 内部应该已经处理了失败的移除
            }
        }
    }
    /**
     * 【新增】定时任务：每分钟打印一次当前 SSE 连接数
     * fixedRate = 60000 表示每 60000 毫秒（即 1 分钟）执行一次
     */
//    @Scheduled(fixedRate = 60000)
//    public void logActiveConnections() {
//        int count = clientEmitters.size(); // 调用获取连接数的方法
//        log.info("【SSE 监控】当前活跃客户端连接数: {}", count);
//    }
//    /**
//     * 向所有活跃的客户端广播消息
//     * @param message 要发送的消息
//     */
//    public void broadcastEvent(String message) {
//        log.debug("广播 {} : {}", emitters.size(), message);
//        // 使用 CopyOnWriteArrayList 的迭代器是安全的，即使在迭代过程中有元素被移除
//        emitters.forEach(emitterWithId -> {
//            try {
//                // 发送带有事件名称的消息
//                emitterWithId.emitter().send(SseEmitter.event().name("newOrder").data(message));
//                log.trace("消息发送成功 ID: {}", emitterWithId.id());
//            } catch (IOException e) {
//                log.warn("消息发送失败 ID: {}. 删除连接", emitterWithId.id(), e);
//                // 移除失败的 emitter
//                emitters.remove(emitterWithId);
//                emitterWithId.emitter().completeWithError(e);
//            }
//        });
//    }

    // 内部类，用于将 SseEmitter 和其唯一ID关联起来
    private record SseEmitterWithId(SseEmitter emitter, long id) {}
}
