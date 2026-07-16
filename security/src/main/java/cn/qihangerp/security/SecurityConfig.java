package cn.qihangerp.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import jakarta.servlet.DispatcherType;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    @Autowired
    private AuthenticationExceptionHandler invalidAuthenticationEntryPoint;
    /**
     * 退出处理类
     */
    @Autowired
    private LogoutSuccessHandlerImpl logoutSuccessHandler;
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public JwtAuthenticationTokenFilter authenticationJwtTokenFilter() {
        return new JwtAuthenticationTokenFilter();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
                // CORS跨域配置
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                // 禁用basic明文验证
                .httpBasic(AbstractHttpConfigurer::disable)
                // 前后端分离架构不需要csrf保护
                .csrf(AbstractHttpConfigurer::disable)
                // 禁用默认登录页
                .formLogin(AbstractHttpConfigurer::disable)
                // 禁用默认登出页
//                .logout().disable()
                // 设置异常的EntryPoint，如果不设置，默认使用Http403ForbiddenEntryPoint
                .exceptionHandling(exceptions -> exceptions.authenticationEntryPoint(invalidAuthenticationEntryPoint))
                // 前后端分离是无状态的，不需要session了，直接禁用。
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authorizeHttpRequests -> authorizeHttpRequests
                        // 放行异步调度（SseEmitter等）
                        .dispatcherTypeMatchers(DispatcherType.ASYNC).permitAll()
                        // 允许所有OPTIONS请求
                        .requestMatchers("/home").permitAll()
                        .requestMatchers(HttpMethod.GET, "/favicon.ico").permitAll()
                        .requestMatchers(HttpMethod.GET, "/tao/order/get_detail").permitAll()
                        .requestMatchers(HttpMethod.GET, "/*/order/get_detail").permitAll()
                        .requestMatchers(HttpMethod.GET, "/refund/get_detail").permitAll()
                        .requestMatchers(HttpMethod.GET, "/images/preview/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/system/config/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/captchaImage").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/sys-api/captchaImage").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/sys-api/system/config/**").permitAll()
                        .requestMatchers("/pdd/oauth_callback").permitAll()
                        // 允许直接访问授权登录接口
                        .requestMatchers(HttpMethod.POST, "/login").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/sys-api/login").permitAll()
                        // SSE 推送通知放行
                        .requestMatchers("/api/erp-api/sse/notify_msg").permitAll()
                        // AI简报接口放行
                        .requestMatchers(HttpMethod.GET, "/api/ai/brief").permitAll()
                        // 允许 SpringMVC 的默认错误地址匿名访问
                        .requestMatchers("/error").permitAll()
                        // 其他所有接口必须有Authority信息，Authority在登录成功后的UserDetailsImpl对象中默认设置"ROLE_USER"
                        //.requestMatchers("/**").hasAnyAuthority("ROLE_USER")
                        // 允许任意请求被已登录用户访问，不检查Authority
                        .anyRequest().authenticated())

                .authenticationProvider(authenticationProvider())
                // 加我们自定义的过滤器，替代UsernamePasswordAuthenticationFilter
                .addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);
        // 添加Logout filter
        http.logout(logout -> logout.logoutUrl("/api/sys-api/logout").logoutSuccessHandler(logoutSuccessHandler));
        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        // 调用 JwtUserDetailService实例执行实际校验
        return username -> userDetailsService.loadUserByUsername(username);
    }

    /**
     * 调用loadUserByUsername获得UserDetail信息，在AbstractUserDetailsAuthenticationProvider里执行用户状态检查
     *
     * @return
     */
    @Bean
    public AuthenticationProvider authenticationProvider() {
        // DaoAuthenticationProvider 从自定义的 userDetailsService.loadUserByUsername 方法获取UserDetails
        // Spring Security 7.x: 构造器直接传入 UserDetailsService
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider(userDetailsService());
        // 设置密码编辑器
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    /**
     * 登录时需要调用AuthenticationManager.authenticate执行一次校验
     *
     * @param config
     * @return
     * @throws Exception
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * CORS配置 - Spring Boot 4.1 / Spring Security 7.x 需要显式配置
     */
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.addAllowedOriginPattern("*");
        configuration.addAllowedMethod("*");
        configuration.addAllowedHeader("*");
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }


}
