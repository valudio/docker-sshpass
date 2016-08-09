FROM node:slim
MAINTAINER Valudio <development@valudio.com>

# Locale issue
ENV LC_ALL="POSIX" \
    METEOR_VERSION=latest 

RUN apt-get update && apt-get -y install sshpass
CMD ["bash"]