FROM mhart/alpine-node:latest
MAINTAINER Valudio <development@valudio.com>

RUN apk update && apk add --no-cache openssh sshpass

VOLUME /app

WORKDIR /app

EXPOSE 3000
CMD ["bash"]