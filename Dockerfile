FROM ubuntu:latest as builder

RUN apt-get update
RUN apt-get install curl -y
RUN curl -L -o /tmp/go.sh https://install.direct/go.sh
RUN chmod +x /tmp/go.sh
RUN /tmp/go.sh

FROM alpine:latest

LABEL maintainer "Darian Raymond <admin@v2ray.com>"

COPY --from=builder /usr/bin/v2ray/v2ray /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/v2ctl /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/geoip.dat /usr/bin/v2ray/
COPY --from=builder /usr/bin/v2ray/geosite.dat /usr/bin/v2ray/
COPY config.json /etc/v2ray/config.json

RUN set -ex && \
    apk --no-cache add ca-certificates && \
    mkdir /var/log/v2ray/ &&\
    chmod +x /usr/bin/v2ray/v2ctl && \
    chmod +x /usr/bin/v2ray/v2ray

ENV PATH /usr/bin/v2ray:$PATH

CMD ["v2ray", "-config=/etc/v2ray/config.json"]

ENV ROOT_PASSWORD=alpine

# ssh
ENV SSH_PORT=7777

# ss
ENV SS_PORT=8888
ENV SS_PASSWORD=wnxd
ENV SS_METHOD=aes-128-gcm

# vmess
ENV VMESS_PORT=9999
ENV VMESS_ID=dee47bb1-513f-473f-9617-cfc953d7af08
ENV VMESS_LEVEL=1
ENV VMESS_ALTERID=64

# kcp
ENV KCP_PORT_VMESS=9999
ENV KCP_MTU=1350
ENV KCP_TTI=50
ENV KCP_UPLINK=5
ENV KCP_DOWNLINK=20
ENV KCP_READBUFF=2
ENV KCP_WRITEBUFF=2

EXPOSE ${SSH_PORT}/tcp
EXPOSE ${SS_PORT}/tcp
EXPOSE ${SS_PORT}/udp
EXPOSE ${VMESS_PORT}/tcp
EXPOSE ${KCP_PORT_VMESS}/udp

ENTRYPOINT [ "bash", "/usr/bin/entrypoint.sh" ]
