FROM maven:3.9.6-eclipse-temurin-17
WORKDIR /app
COPY target/Demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 9001
ENTRYPOINT ["java", "-jar", "app.jar"]
