# pluggables: Tor Transport Plugin Binary Builder
FROM  golang:alpine3.20
ARG LYREBIRD_VERSION=0.2.0
WORKDIR /

RUN apk add -U --no-cache bash make git

SHELL ["/bin/bash", "-c"]
RUN set -ex && cd /tmp && \
    wget "https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird/-/archive/lyrebird-${LYREBIRD_VERSION}/lyrebird-lyrebird-${LYREBIRD_VERSION}.tar.gz" && \
    tar -xvf lyrebird-lyrebird-${LYREBIRD_VERSION}.tar.gz && \
    pushd lyrebird-lyrebird-${LYREBIRD_VERSION} && \
    go get -u ./... && \
    go mod tidy && \
    make build -e VERSION=${LYREBIRD_VERSION} && \
    cp ./lyrebird /usr/local/bin && \
    popd && \
    rm -rf /go /tmp/* && \
    echo "DONE LYREBIRD AKA OBFS4" 
RUN git clone https://git.torproject.org/pluggable-transports/snowflake.git \
    && cd snowflake/client \
    && CGO_ENABLED=0 go build -a -installsuffix cgo \
    && echo "DONE SNOWFLAKE"
RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel.git \
    && cd webtunnel/main/client \
    && CGO_ENABLED=0 go build -a -installsuffix cgo \
    && echo "DONE WEBTUNNEL" 