#----------------------------------
# Stage 1 - Build Application
#----------------------------------

# Upgrade Maven & JDK base image
FROM maven:3.9.6-eclipse-temurin-17 as builder 

# Set working directory
WORKDIR /app

# Copy source code from local to container
COPY . /app

# Upgrade dependencies & cache Maven repository
RUN mvn clean install -DskipTests=true -Dmaven.repo.local=/app/.m2/repository


#--------------------------------------
# Stage 2 - Run Application Securely
#--------------------------------------

# Upgrade OpenJDK Alpine base image
FROM eclipse-temurin:17-jre-alpine as deployer

# Update system packages to fix vulnerabilities
RUN apk update && apk upgrade --no-cache

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Set working directory
WORKDIR /app

# Copy only the built JAR file from the build stage
COPY --from=builder /app/target/*.jar /app/bankapp.jar

# Expose application port
EXPOSE 8080

# Start the application securely
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/bankapp.jar"]
