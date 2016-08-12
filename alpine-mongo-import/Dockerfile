FROM alpine:latest
MAINTAINER Valudio <development@valudio.com>

COPY import.sh import.sh
RUN apk update && apk add --no-cache openssh sshpass

EXPOSE 3000
CMD ["sh", "import.sh"]