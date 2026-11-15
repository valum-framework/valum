FROM ubuntu:resolute

MAINTAINER Guillaume Poirier-Morency <guillaumepoiriermorency@gmail.com>

RUN apt-get update && apt-get install -y \
    libfcgi-dev                          \
    libglib2.0-dev                       \
    libsoup2.4-dev                       \
    libssl-dev                           \
    ninja-build                          \
    unzip                                \
    valac                                \
    meson                                \
    && rm -rf /var/lib/apt/lists/*

ADD . /valum

RUN cd /valum && mkdir build && meson --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu --buildtype=release . build && ninja -C build && ninja -C build test && ninja -C build install

RUN rm -rf /valum
