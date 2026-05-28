FROM maven:3.9-eclipse-temurin-21

# Instalar dependencias del sistema (Chrome + utilities)
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg \
    xvfb \
    chromium \
    chromium-driver \
    fonts-liberation \
    libnss3 \
    libxss1 \
    libappindicator3-1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Variables para Selenium/Chrome headless
ENV CHROME_BIN=/usr/bin/chromium
ENV DISPLAY=:99

# Directorio de trabajo
WORKDIR /tests

# Copiar proyecto completo
COPY . .

# Ejecutar tests por defecto
CMD ["mvn", "clean", "test"]