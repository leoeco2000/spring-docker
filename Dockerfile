FROM openjdk:8-jdk-alpine

VOLUME /tmp

ARG JAR_FILE

ADD target/${JAR_FILE} app.jar

RUN sh -c 'touch /app.jar'

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
#对外端口
EXPOSE 8081