# ---------- build (Gradle + Java 21) ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# copie o wrapper e configs do Gradle primeiro (cache melhor)
COPY gradlew gradlew.bat settings.gradle build.gradle ./
COPY gradle ./gradle

# copie o código
COPY src ./src

# garanta permissão de execução do wrapper (importante no Render)
RUN chmod +x gradlew

# build do jar (sem testes)
RUN ./gradlew clean bootJar -x test

# ---------- runtime (JRE 21, não-root) ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

ENV PORT=8080 JAVA_OPTS=""

# copie o jar buildado
COPY --from=build /app/build/libs/*.jar /app/app.jar

EXPOSE 8080

# usuário não-root
RUN useradd -r -u 1001 appuser && chown appuser:appuser /app/app.jar
USER appuser

# respeita a porta do Render
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar --server.port=${PORT}"]
