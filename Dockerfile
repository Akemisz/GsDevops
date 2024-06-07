# Define a imagem base utilizando o JDK 11 Slim para melhor desempenho
FROM openjdk:11-jdk-slim as build

# Define o argumento JAVA_OPTS com um valor padrão
ARG JAVA_OPTS="-Xmx512m"
ENV JAVA_OPTS=${JAVA_OPTS}

# Define o diretório de trabalho no contêiner
WORKDIR /app

# Adiciona um novo usuário 'appuser' sem privilégios administrativos
RUN adduser --disabled-password --gecos '' appuser

# Copia o arquivo pom.xml e os diretórios src para o diretório de trabalho
COPY pom.xml .
COPY src /app/src

# Usa Maven wrapper incluído no projeto para compilar e empacotar a aplicação
# Assume que o mvnw e .mvn estão presentes no diretório raiz do projeto
COPY mvnw .mvn /app/
RUN ./mvnw clean package -Duser.home=/app

# Etapa final, baseada na imagem JRE para reduzir o tamanho da imagem final
FROM openjdk:11-jre-slim

# Copia o artefato da construção anterior e define o diretório de trabalho
COPY --from=build /app/target/*.jar /app/app.jar
WORKDIR /app

# Define o usuário 'appuser' para executar a aplicação
USER appuser

# Expõe a porta 8080
EXPOSE 8080

# Cria um volume para persistência de dados
VOLUME /app/data

# Comando para executar a aplicação
CMD ["java", "${JAVA_OPTS}", "-jar", "app.jar"]
