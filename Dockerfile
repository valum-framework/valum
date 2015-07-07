FROM ubuntu:latest

MAINTAINER Anton Vasiljev <antono.vasiljev@gmail.com>

RUN apt-get update --quiet && apt-get install --yes software-properties-common
RUN add-apt-repository ppa:vala-team && apt-get update --quiet
RUN apt-get install --yes valac libglib2.0-bin libglib2.0-dev libsoup2.4-dev \
                          libgee-0.8-dev libfcgi-dev libjson-glib-dev \
                          libmemcached-dev libluajit-5.1-dev libctpl-dev

COPY . /valum
WORKDIR /valum

RUN ./waf configure --prefix=/usr
RUN ./waf build
RUN ./waf install
EXPOSE 3003

CMD ./build/examples/app/app
