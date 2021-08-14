FROM alpine:latest

RUN apk add --no-cache openssh openssh-sftp-server
RUN adduser -DH default

EXPOSE 22

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
