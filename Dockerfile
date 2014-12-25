FROM ubuntu:vivid

MAINTAINER Anton Vasiljev <antono.vasiljev@gmail.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu vivid main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install -y git-core build-essential valac libgee-0.8-dev \
    libsoup2.4-dev libjson-glib-dev memcached libmemcached-dev \
    libluajit-5.1-dev libctpl-dev

EXPOSE 3000
EXPOSE 3003

COPY . /src
RUN cd /src && make

WORKDIR /src

CMD ["make", "run"]
