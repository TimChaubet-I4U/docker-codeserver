# File: Dockerfile
# Author: Tim Chaubet

ARG LS_TAG=latest
FROM linuxserver/code-server:${LS_TAG}

ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# Step 1: Core OS Utilities
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y vim ca-certificates curl gnupg lsb-release build-essential libgraphviz-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 2: External Repositories (Docker & NodeSource)
# We handle GPG keys first to avoid 'apt-get update' errors later
RUN mkdir -m 0755 -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Step 3: Main Package Installation
# CRITICAL: We removed 'npm' from this list to prevent Exit Code 100
RUN apt-get update && \
    apt-get install -y \
        docker-ce-cli \
        nodejs \
        python3 \
        python3-pip \
        python3-venv \
        git \
        php \
        composer \
        php-codesniffer \
        golang \
        gcc \
        g++ \
        mypy \
        tree \
        python3-mypy && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 4: Application Logic
# Note: Since 'npm' is now provided by the 'nodejs' package, this works fine
RUN npm install -g npm@11.1.0 && \
    cd /app/code-server/lib/vscode && \
    npm install --force && \
    npm audit fix

# Step 5: Final Permissions
RUN usermod -aG sudo abc

EXPOSE 8443
VOLUME ["/config"]