package cn.qihangerp.security;


import cn.qihangerp.common.AjaxResult;
import cn.qihangerp.enums.HttpStatus;
import com.alibaba.fastjson2.JSON;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * token过滤器 验证token有效性
 * 
 * @author qihang
 */
@Component
public class JwtAuthenticationTokenFilter extends OncePerRequestFilter {
    @Autowired
    private TokenService tokenService;
    /**
     * 需要拦截的请求头信息
     */
    @Value("${token.header:'Authorization'}")
    public String TOKEN_HEADER = "Authorization";
    private Logger log = LoggerFactory.getLogger(getClass());

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
//        String token = exchange.getRequest().getHeaders().getFirst(TOKEN_HEADER);
//        String token = request.getHeader("Authorization");
//        if(StringUtils.isEmpty(token)){
//            token = request.getParameter("token");
//        }
        String url = request.getRequestURI();
//        log.info("intercept " + url);
//        log.info("token: " + token); || request.getRequestURI().equals("/getInfo") || request.getRequestURI().equals("/logout")
        if (request.getRequestURI().equals("/login")
                || url.contains("/login")
                || url.contains("/captchaImage")
                || url.contains("/order/get_detail")
                || url.contains("/refund/get_detail")
                || url.contains("/system/config")
                || url.contains("/oauth_callback")
                || url.contains("/sse/notify_msg")
                // 图片预览：<img> 标签不会携带 Authorization 头，必须在此白名单放行，
                // 否则会在 Spring Security 的 permitAll 之前被本过滤器返回“授权过期”
                || url.contains("/images/preview")
        ) {
            // 登录页面，放行 || request.getRequestURI().equals("/order/get_detail")
            chain.doFilter(request, response);
            return;
        }
        LoginUser loginUser = tokenService.getLoginUser(request);
        if (loginUser != null) {
            tokenService.verifyToken(loginUser);
            UsernamePasswordAuthenticationToken authenticationToken = new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities());
            authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
            SecurityContextHolder.getContext().setAuthentication(authenticationToken);
        } else {
            fallback(" 授权过期！", response);
            return;
        }
        chain.doFilter(request, response);
    }

    private void fallback(String message, HttpServletResponse response) {
        response.setCharacterEncoding("UTF-8");
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        PrintWriter writer = null;
        try {
            if (message == null) {
                message = "401 Forbidden";
            }
            AjaxResult res = AjaxResult.error(HttpStatus.UNAUTHORIZED, message);
            writer = response.getWriter();
            writer.append(JSON.toJSONString(res));
        } catch (IOException e) {
            log.error(e.getMessage());
        } finally {
            if (writer != null) {
                writer.close();
            }
        }
    }
}
