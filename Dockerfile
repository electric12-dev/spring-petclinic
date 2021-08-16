FROM openjdk:latest

RUN mkdir ./petclinic && cd ./petclinic

COPY ./target/spring-petclinic-2.4.5.jar ./petclinic/spring-petclinic-2.4.5.jar

EXPOSE 8080

CMD ["java","-jar","/petclinic/spring-petclinic-2.4.5.jar"]
