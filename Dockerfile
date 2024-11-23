# compiler: Tor Transport Plugin Binary Builder
FROM golang:1.23.3-alpine3.20@sha256:c694a4d291a13a9f9d94933395673494fc2cc9d4777b85df3a7e70b3492d3574 AS compiler
WORKDIR /
RUN apk add -U --no-cache bash make git upx

# Build lyrebird (obfs4)
RUN git clone --depth=1 https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird.git \
    && cd lyrebird \
    && make build \
    && upx --best --lzma lyrebird \
    && echo "DONE LYREBIRD AKA OBFS4"

# Build snowflake
RUN git clone --depth=1 https://git.torproject.org/pluggable-transports/snowflake.git \
    && cd snowflake/client \
    && CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s -w" \
    && upx --best --lzma client \
    && echo "DONE SNOWFLAKE"

# Build webtunnel
RUN git clone --depth=1 https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel.git \
    && cd webtunnel/main/client \
    && CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags="-s -w" \
    && upx --best --lzma client \
    && echo "DONE WEBTUNNEL"

# Set executable permissions
RUN chmod +x /lyrebird/lyrebird /webtunnel/main/client/client /snowflake/client/client

# Final stage
FROM scratch
LABEL maintainer="NOXCIS"
COPY --from=compiler /lyrebird/lyrebird /lyrebird
COPY --from=compiler /webtunnel/main/client/client /webtunnel
COPY --from=compiler /snowflake/client/client /snowflake
