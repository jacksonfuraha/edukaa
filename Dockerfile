# ── Stage 1: Build the WAR ───────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -DskipTests -q

# ── Stage 2: Run on Tomcat ───────────────────────────────────────────
FROM tomcat:10.1-jdk17
LABEL maintainer="IDUKA"

# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy IDUKA as ROOT app
COPY --from=build /app/target/IDUKA.war /usr/local/tomcat/webapps/ROOT.war

# Upload directories
RUN mkdir -p /tmp/iduka_uploads/products \
             /tmp/iduka_uploads/videos \
             /tmp/iduka_uploads/avatars

EXPOSE 8080
CMD ["catalina.sh", "run"]
