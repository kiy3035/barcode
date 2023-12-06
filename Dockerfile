FROM openjdk:11-jre-slim

WORKDIR /app

COPY build/libs/demo-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8002

CMD ["java", "-jar", "app.jar"]
