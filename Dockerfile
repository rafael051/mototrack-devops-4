# ---------- build (Gradle + Java 21) ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copia wrapper/configs primeiro para melhorar cache
COPY gradlew gradlew.bat settings.gradle build.gradle ./
COPY gradle ./gradle

# Copia o código
COPY src ./src

# Permissão do wrapper (importante em Linux/Render)
RUN chmod +x gradlew

# Build do JAR (sem testes)
RUN ./gradlew clean bootJar -x test


# ---------- runtime (JRE 21, usuário não-root) ----------
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copia o jar buildado
COPY --from=build /app/build/libs/*.jar /app/app.jar

# Expõe a porta padrão do app (Render injeta PORT em runtime)
EXPOSE 8080

# Cria usuário não-root e ajusta permissões
RUN adduser -D -u 10001 appuser && chown appuser:appuser /app/app.jar
USER appuser

# Sobe com profile prod; sem congelar PORT/DB_* (Render injeta)
ENTRYPOINT ["java","-Dspring.profiles.active=prod","-jar","/app/app.jar"]
