FROM ubuntu:22.04

MAINTAINER Guillaume Poirier-Morency <guillaumepoiriermorency@gmail.com>

RUN apt-get update && apt-get install -y \
    libfcgi-dev                          \
    libglib2.0-dev                       \
    libsoup2.4-dev                       \
    ninja-build                          \
    python3-pip                          \
    unzip                                \
    valac                                \
    meson                                \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /valum
ADD . .

RUN mkdir build && meson --prefix=/usr --buildtype=release . build && ninja -C build && meson test -C build && ninja -C build install
