FROM eclipse-temurin:21-jdk

# Instalar herramientas necesarias
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg \
    xvfb \
    chromium \
    chromium-driver \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tests

# Copiar pom.xml primero para cache de dependencias
COPY pom.xml .

# Instalar dependencias Maven
RUN apt-get update && apt-get install -y maven
RUN mvn dependency:resolve

# Copiar proyecto
COPY . .

# Ejecutar pruebas
CMD ["mvn", "test"]
