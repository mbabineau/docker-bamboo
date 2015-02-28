FROM debian:7.8
MAINTAINER Mike Babineau michael.babineau@gmail.com

ENV BAMBOO_RELEASE https://github.com/QubitProducts/bamboo/archive/v0.2.9.tar.gz
ENV BAMBOO_SRC_DIR /opt/go/src/github.com/QubitProducts/bamboo
ENV DEBIAN_FRONTEND noninteractive
ENV GOPATH /opt/go

# Use one step so we can remove intermediate dependencies and minimize size
RUN \
    # Install backports repo for haproxy
    echo "deb http://http.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/backports.list \
    && apt-get update \

    # Install dependencies
    && apt-get install -y git bzr mercurial \
                       golang \
                       curl \
                       haproxy -t wheezy-backports \
    && mkdir -p /run/haproxy \

    # Use apt-provided go to bootstrap the installation of a newer version
    && go get launchpad.net/godeb \
    && apt-get -y remove golang-go \
    && /opt/go/bin/godeb install 1.2.1 \
    && rm go_1.2.1-godeb1_amd64.deb \

    # Build Bamboo dependencies
    && go get github.com/tools/godep \
    && go get -t github.com/smartystreets/goconvey \

    # Fetch Bamboo
    && curl -sLo /tmp/bamboo.tgz $BAMBOO_RELEASE \
    && mkdir -p $BAMBOO_SRC_DIR \
    && tar xzf /tmp/bamboo.tgz -C $BAMBOO_SRC_DIR --strip=1 \
    && rm -rf /tmp/bamboo.tgz \

    # Build Bamboo
    && cd $BAMBOO_SRC_DIR \
    && /opt/go/bin/godep restore \
    && go build \
    && ln -s $BAMBOO_SRC_DIR /opt/bamboo \

    # Remove build-time dependencies
    && apt-get -y purge git bzr mercurial curl golang-go \
    && apt-get -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8000
EXPOSE 80

WORKDIR /opt/bamboo
CMD ["--help"]
ENTRYPOINT ["/opt/bamboo/bamboo"]
