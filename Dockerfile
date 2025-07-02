FROM pandoc/extra:latest-ubuntu

# =====================
# Variabili di build
# =====================
ARG JAVA_VERSION=21.0.7+6
ARG JAVA_VERSION_UNDERSCORE=21.0.7_6
ARG PLANTUML_VERSION=1.2025.4
ARG DIAGRAM_VERSION=1.2.0
ARG PLANTUML_JAR_URL=https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar
ARG DIAGRAM_URL=https://github.com/pandoc-ext/diagram/archive/refs/tags/v${DIAGRAM_VERSION}.tar.gz

# Variabili di ambiente
ENV JAVA_HOME=/opt/java
ENV PATH="$JAVA_HOME/bin:$PATH"

# =====================
# Sistema base e tool
# =====================
RUN apt-get update \
    && apt-get install -y curl graphviz nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Installa mermaid-cli globalmente
RUN npm install -g @mermaid-js/mermaid-cli

# =====================
# Java (Temurin JRE)
# =====================

# =====================
# Installazione automatica di Eclipse Temurin JRE (multi-arch)
# =====================
RUN set -eux; \
    ARCH="$(uname -m)"; \
    if [ "$ARCH" = "x86_64" ]; then \
        JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JAVA_VERSION}/OpenJDK21U-jre_x64_linux_hotspot_${JAVA_VERSION_UNDERSCORE}.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-${JAVA_VERSION}/OpenJDK21U-jre_aarch64_linux_hotspot_${JAVA_VERSION_UNDERSCORE}.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi; \
    mkdir -p /opt/java; \
    curl -fsSL "$JRE_URL" | tar -xz --strip-components=1 -C /opt/java; \
    ln -sf /opt/java/bin/java /usr/bin/java

ENV PATH="$JAVA_HOME/bin:$PATH"

# Variabile versione PlantUML
ENV PLANTUML_VERSION=1.2025.4
ENV PLANTUML_JAR_URL="https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar"

# =====================
# PlantUML (jar + shortcut)
# =====================
RUN mkdir -p /opt/plantuml \
    && curl -fsSL "$PLANTUML_JAR_URL" -o /opt/plantuml/plantuml.jar \
    && echo '#!/bin/sh\nexec java -jar /opt/plantuml/plantuml.jar "$@"' > /usr/local/bin/plantuml \
    && chmod +x /usr/local/bin/plantuml

# =====================
# Pandoc-ext Diagram Filter
# =====================
RUN mkdir -p /usr/local/share/pandoc/filters/diagram-ext \
    && curl -fsSL "$DIAGRAM_URL" | tar -xz --strip-components=1 -C /usr/local/share/pandoc/filters/diagram-ext \
    && chmod -R a+rX /usr/local/share/pandoc/filters/diagram-ext
