# -----------------------------------------------------------------------------
# STAGE 1: Build
# -----------------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /app

# 1. Copy the Project Structure
COPY pom.xml .
COPY shared-lib/ shared-lib/
COPY service-two/ service-two/

# 2. Build ONLY this service
RUN mvn clean package -pl service-two -am -DskipTests

# -----------------------------------------------------------------------------
# STAGE 2: Runtime
# -----------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/service-two/target/*.jar app.jar

# Expose the port (Documentation only)
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]