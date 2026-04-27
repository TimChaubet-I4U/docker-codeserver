# File: Dockerfile
# Author: Tim Chaubet

ARG LS_TAG=latest
FROM linuxserver/code-server:${LS_TAG}

ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io fork version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="tim@chaubet.be"

ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

COPY ./requirements.txt requirements.txt

RUN \
  echo "**** install core dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    vim \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    build-essential \
    libgraphviz-dev && \
  \
  echo "**** setup docker repo ****" && \
  mkdir -m 0755 -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  \
  echo "**** setup nodejs repo ****" && \
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  \
  echo "**** install packages ****" && \
  apt-get update && \
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
  \
  echo "**** configure node and app ****" && \
  npm install -g npm@11.1.0 && \
  cd /app/code-server/lib/vscode && \
  npm install --force && \
  npm audit fix && \
  \
  echo "**** cleanup ****" && \
  usermod -aG sudo abc && \
  apt-get purge -y --auto-remove && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

EXPOSE 8443
VOLUME ["/config"]