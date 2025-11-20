# syntax=docker/dockerfile:1

# -----------------------------------------------------------------------------
# STAGE 1: Cache & Build
# -----------------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app

# 1. COPY THE POM SKELETON
COPY pom.xml .
COPY shared-lib/pom.xml shared-lib/
COPY service-one/pom.xml service-one/
COPY service-two/pom.xml service-two/

# 2. DOWNLOAD DEPENDENCIES
RUN --mount=type=cache,target=/root/.m2 \
    mvn dependency:go-offline -pl service-one -am

# 3. COPY SOURCE CODE
COPY shared-lib/src shared-lib/src
COPY service-one/src service-one/src

# 4. BUILD
RUN --mount=type=cache,target=/root/.m2 \
    mvn clean package -pl service-one -am -DskipTests

# -----------------------------------------------------------------------------
# STAGE 2: Runtime
# -----------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/service-one/target/*.jar app.jar

# Expose the port (Documentation only)
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]