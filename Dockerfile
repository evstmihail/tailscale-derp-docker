FROM alpine:latest AS builder

RUN apk add --no-cache go --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
RUN go install tailscale.com/cmd/derper@main

FROM alpine:latest

LABEL org.opencontainers.image.source="https://github.com/evstmihail/tailscale-derp-docker"

RUN apk add --no-cache curl iptables \
    && apk add --no-cache tailscale --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

COPY --from=builder /root/go/bin/derper /usr/local/bin/derper

COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 80 443/tcp 3478/udp

ENTRYPOINT ["/init.sh"]
