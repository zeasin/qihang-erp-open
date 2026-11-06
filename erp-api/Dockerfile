# ---------- 运行阶段：JRE 运行 jar ----------
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY ./erp-api/target/erp-api-4.1.0.jar erp-api.jar
EXPOSE 6149
CMD ["java", "-Duser.timezone=Asia/Shanghai", "-jar", "erp-api.jar"]
