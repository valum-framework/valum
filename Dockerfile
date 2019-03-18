FROM ubuntu:xenial

MAINTAINER Guillaume Poirier-Morency <guillaumepoiriermorency@gmail.com>

RUN apt-get update && apt-get install -y \
    libfcgi-dev                          \
    libglib2.0-dev                       \
    libsoup2.4-dev                       \
    libssl-dev                           \
    ninja-build                          \
    python3-pip                          \
    unzip                                \
    valac                                \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install meson

WORKDIR /valum
ADD . .

RUN mkdir build && meson --prefix=/usr --buildtype=release . build && ninja -C build && ninja -C build test && ninja -C build install
