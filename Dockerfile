# File: .github/workflows/sync-and-rebuild.yml
# Author: Tim Chaubet

ARG LS_TAG=latest
FROM linuxserver/code-server:${LS_TAG}

ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io fork version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="tim@chaubet.be"

# Set environment variables
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

# Copy requirements for python/pip if needed
COPY ./requirements.txt requirements.txt

# Step 1: Core OS Utilities & System Upgrade
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        vim \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        build-essential \
        libgraphviz-dev

# Step 2: Setup External Repositories (Docker & NodeSource 20)
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Step 3: Main Package Installation & Final Cleanup
# 'npm' is excluded as NodeSource 'nodejs' provides it.
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
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    apt-get clean -y && \
    rm -rf /config/* /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Step 4: Application Specific Logic (NPM Upgrade & VS Code Libs)
RUN npm install -g npm@11.1.0 && \
    cd /app/code-server/lib/vscode && \
    npm install --force && \
    npm audit fix

# Step 5: Final Permissions and User Setup
RUN usermod -aG sudo abc

EXPOSE 8443
VOLUME ["/config"]