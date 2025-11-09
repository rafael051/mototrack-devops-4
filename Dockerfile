# ===== Build Stage =====
FROM gradle:8.10.2-jdk21-alpine AS build
WORKDIR /app
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
RUN ./gradlew --version
COPY . .
RUN ./gradlew clean build -x test

# ===== Run Stage =====
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
ENV PORT=8080
EXPOSE 8080
COPY --from=build /app/build/libs/*.jar /app/app.jar
ENTRYPOINT ["java","-XX:+UseContainerSupport","-XX:MaxRAMPercentage=75.0","-jar","/app/app.jar"]
