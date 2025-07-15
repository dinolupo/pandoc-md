FROM pandoc/extra:latest-ubuntu

# Variabili
ARG JAVA_VERSION=21.0.7+6
ARG JAVA_VERSION_FILE=21.0.7_6
ARG PLANTUML_VERSION=1.2025.4
ARG DIAGRAM_VERSION=1.2.0
ARG PLANTUML_JAR_URL=https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar
ARG DIAGRAM_URL=https://github.com/pandoc-ext/diagram/archive/refs/tags/v${DIAGRAM_VERSION}.tar.gz

ENV JAVA_HOME=/opt/java
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV DEBIAN_FRONTEND=noninteractive

# Sistema base + NodeJS + dipendenze Puppeteer
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    patch \
    graphviz \
    inkscape \
    unzip \
    nodejs \
    npm \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libasound2t64 \
    libnss3 \
    libxss1 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libxext6 \
    libxfixes3 \
    libgbm1 \
    libgdk-pixbuf2.0-0 \
    libpango-1.0-0 \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# JRE
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "x86_64" ]; then \
    JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JAVA_VERSION}/OpenJDK21U-jre_x64_linux_hotspot_${JAVA_VERSION_FILE}.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
    JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JAVA_VERSION}/OpenJDK21U-jre_aarch64_linux_hotspot_${JAVA_VERSION_FILE}.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi; \
    mkdir -p /opt/java; \
    curl -fsSL "$JRE_URL" | tar -xz --strip-components=1 -C /opt/java; \
    ln -sf /opt/java/bin/java /usr/bin/java

# PlantUML + Batik
ARG BATIK_ZIP_URL=https://archive.apache.org/dist/xmlgraphics/batik/binaries/batik-bin-1.17.zip
ARG COMMONS_IO_URL=https://repo1.maven.org/maven2/commons-io/commons-io/2.11.0/commons-io-2.11.0.jar

RUN mkdir -p /opt/plantuml /opt/batik/lib \
    && curl -fsSL "$PLANTUML_JAR_URL" -o /opt/plantuml/plantuml.jar \
    && curl -fsSL "$BATIK_ZIP_URL" -o /tmp/batik.zip \
    && unzip /tmp/batik.zip -d /opt/batik \
    && mv /opt/batik/batik-1.17/lib/* /opt/batik/lib/ \
    && rm -rf /tmp/batik.zip /opt/batik/batik-1.17 \
    && curl -fsSL "$COMMONS_IO_URL" -o /opt/batik/lib/commons-io.jar \
    && echo '#!/bin/sh\nexec java -Djava.awt.headless=true -cp "/opt/plantuml/plantuml.jar:/opt/batik/lib/*" net.sourceforge.plantuml.Run "$@"' > /usr/local/bin/plantuml \
    && chmod +x /usr/local/bin/plantuml

# Mermaid CLI e Chrome headless
RUN npm install -g @puppeteer/browsers @mermaid-js/mermaid-cli

# diagram.lua
RUN mkdir -p /tmp/diagram-ext \
 && curl -fsSL "$DIAGRAM_URL" | tar -xz --strip-components=1 -C /tmp/diagram-ext \
 && cp /tmp/diagram-ext/_extensions/diagram/diagram.lua /usr/local/share/pandoc/filters/diagram.lua \
 && chmod a+rX /usr/local/share/pandoc/filters/diagram.lua \
 && rm -rf /tmp/diagram-ext

# Copia il file nel path predefinito
COPY puppeteer-config.json /root/.puppeteer.json
COPY diagram.lua /usr/local/share/pandoc/filters/diagram.lua
RUN tlmgr install lastpage

RUN mkdir -p /data && chmod -R 777 /data
WORKDIR /data
