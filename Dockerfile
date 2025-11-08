# ---------- build (Maven + Java 21) ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -e -DskipTests clean package

# ---------- runtime (JRE 21 leve, não-root) ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# (opcional) variáveis úteis
ENV PORT=8080 \
    JAVA_OPTS=""

# copia o jar gerado
COPY --from=build /app/target/mototrack-0.0.1-SNAPSHOT.jar /app/app.jar

# porta de aplicação (local) — no Render ele injeta $PORT
EXPOSE 8080

# usuário não-root
RUN useradd -r -u 1001 appuser && chown appuser:appuser /app/app.jar
USER appuser

# importante: respeitar a porta do Render
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar --server.port=${PORT}"]
