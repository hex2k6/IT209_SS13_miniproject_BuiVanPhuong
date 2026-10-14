# Build and test with the same Gradle version as gradle-wrapper.properties.
FROM gradle:8.14.3-jdk21 AS build
WORKDIR /workspace
COPY backend/gradlew backend/settings.gradle backend/build.gradle ./
COPY backend/gradle ./gradle
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew
COPY backend/src ./src
RUN gradle --no-daemon test bootJar

FROM eclipse-temurin:21-jre-jammy AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system spring && useradd --system --gid spring spring
WORKDIR /app
COPY --from=build --chown=spring:spring /workspace/build/libs/campus-hub-1.0.0.jar app.jar
USER spring:spring
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
