FROM linuxserver/code-server:latest
ARG BUILD_DATE
ARG VERSION
ARG CODE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
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
    git \
    php \
    composer \
    php-codesniffer && \
  apt-get upgrade -y && \
  apt-get clean 
RUN apt-get update && \
  apt-get install -y \
    build-essential \
    libgraphviz-dev && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* && \ 
  usermod -aG sudo abc 2>&1
#RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir f5-sphinx-theme Sphinx sphinx-autobuild \
    sphinx-rtd-theme sphinxcontrib-addmetahtml sphinxcontrib-blockdiag \
    sphinxcontrib-googleanalytics sphinxcontrib-images sphinxcontrib-nwdiag \
    sphinxcontrib-websupport sphinxjp.themes.basicstrap recommonmark \
    restview myst-parser

EXPOSE 8443
VOLUME ["/config"]
