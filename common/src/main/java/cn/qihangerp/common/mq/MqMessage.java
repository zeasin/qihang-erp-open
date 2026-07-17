package cn.qihangerp.common.mq;

import cn.qihangerp.enums.EnumShopType;
import lombok.Data;

@Data
public class MqMessage {
    private int mqType;
    private EnumShopType shopType;
    private String keyId;
    private String data1;
    private String data2;

    public static MqMessage build(EnumShopType shopType,int mqType ,  String keyId){
        MqMessage result = new MqMessage();
        result.setShopType(shopType);
        result.setMqType(mqType);
        result.setKeyId(keyId);
        return result;
    }

    public static MqMessage build(EnumShopType shopType,int mqType ,  String orderNum,String logisticsCompany,String logisticsCode){
        MqMessage result = new MqMessage();
        result.setShopType(shopType);
        result.setMqType(mqType);
        result.setKeyId(orderNum);
        result.setData1(logisticsCompany);
        result.setData2(logisticsCode);
        return result;
    }
}
