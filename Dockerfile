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
    python3-pip \
    git \
    php \
    composer \
    php-codesniffer && \
  apt-get upgrade -y && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* && \ 
  usermod -aG sudo abc 2>&1
#RUN pip install --no-cache-dir -r requirements.txt
pip3 install --no-cache-dir f5-sphinx-theme
pip3 install --no-cache-dir Sphinx
pip3 install --no-cache-dir sphinx-autobuild
pip3 install --no-cache-dir sphinx-rtd-theme
pip3 install --no-cache-dir sphinxcontrib-addmetahtml
pip3 install --no-cache-dir sphinxcontrib-blockdiag
pip3 install --no-cache-dir sphinxcontrib-googleanalytics
pip3 install --no-cache-dir sphinxcontrib-images
pip3 install --no-cache-dir sphinxcontrib-nwdiag
pip3 install --no-cache-dir sphinxcontrib-websupport
pip3 install --no-cache-dir sphinxjp.themes.basicstrap
pip3 install --no-cache-dir recommonmark
pip3 install --no-cache-dir restview
pip3 install --no-cache-dir myst-parser

EXPOSE 8443
VOLUME ["/config"]
