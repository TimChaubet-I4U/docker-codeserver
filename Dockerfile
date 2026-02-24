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
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    vim \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
  mkdir -m 0755 -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list 2>&1 && \
  apt-get update && \
  apt-get install -y \
    docker-ce-cli \
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
    npm \
    mypy \
    tree \
    python3-mypy && \
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs && \
  apt-get upgrade -y && \
  apt-get clean && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libgraphviz-dev && \
  apt-get remove -y nodejs npm && \
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g npm@11.1.0 && \
  cd /app/code-server/lib/vscode && \
  npm install --force && \
  npm audit fix && \
  apt-get autoremove -y && \
  apt-get autoclean -y && \
  apt-get clean -y && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* && \
  usermod -aG sudo abc 2>&1

EXPOSE 8443
VOLUME ["/config"]