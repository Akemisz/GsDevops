# Utiliza uma imagem base com Maven e JDK 11
FROM maven:3.8.6-jdk-11-slim as build

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Copia o arquivo pom.xml e os diretórios src para o diretório de trabalho
COPY pom.xml .
COPY src /app/src

# Compila o projeto e empacota o executável
RUN mvn clean package

# Etapa para executar a aplicação
FROM openjdk:11-jre-slim
COPY --from=build /app/target/*.jar /app/app.jar
WORKDIR /app

# Expõe a porta 8080 para a aplicação
EXPOSE 8080

# Define o volume no diretório /app/data
VOLUME /app/data

# Comando para executar a aplicação
CMD ["java", "-jar", "app.jar"]
