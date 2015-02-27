FROM debian:7.8
MAINTAINER Mike Babineau michael.babineau@gmail.com

ENV BAMBOO_RELEASE https://github.com/QubitProducts/bamboo/archive/v0.2.4.tar.gz
ENV BAMBOO_SRC_DIR /opt/go/src/github.com/QubitProducts/bamboo
ENV DEBIAN_FRONTEND noninteractive
ENV GOPATH /opt/go

# Install dependencies
RUN echo "deb http://cdn.debian.net/debian wheezy-backports main" > /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install -y git bzr mercurial \
                       golang \
                       curl \
                       haproxy -t wheezy-backports \
    && mkdir -p /run/haproxy

# Use apt-provided go to bootstrap the installation of a newer version
RUN go get launchpad.net/godeb \
    && apt-get -y remove golang-go \
    && /opt/go/bin/godeb install 1.2.1 \
    && rm go_1.2.1-godeb1_amd64.deb

RUN curl -sLo /tmp/bamboo.tgz $BAMBOO_RELEASE \
    && mkdir -p $BAMBOO_SRC_DIR \
    && tar xzf /tmp/bamboo.tgz -C $BAMBOO_SRC_DIR --strip=1 \
    && rm -rf /tmp/bamboo.tgz

RUN go get github.com/tools/godep \
    && go get -t github.com/smartystreets/goconvey

RUN cd $BAMBOO_SRC_DIR \
    && /opt/go/bin/godep restore \
    && go build \
    && ln -s $BAMBOO_SRC_DIR /opt/bamboo

EXPOSE 8000
EXPOSE 80

WORKDIR /opt/bamboo
CMD ["--help"]
ENTRYPOINT ["/opt/bamboo/bamboo"]
