FROM ubuntu:precise

MAINTAINER Anton Vasiljev <antono.vasiljev@gmail.com>

RUN apt-get install -y python-software-properties
RUN add-apt-repository --yes ppa:vala-team
RUN apt-get update --quiet
RUN apt-get install -y git valac-0.26 libglib2.0-bin libglib2.0-dev \
                       libsoup2.4-dev libgee-0.8-dev libfcgi-dev \
                       libmemcached-dev libluajit-5.1-dev libctpl-dev

RUN git clone https://github.com/valum-framework/valum.git

WORKDIR valum

EXPOSE 3003

RUN ./waf configure && ./waf build

CMD build/examples/app/app
