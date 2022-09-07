FROM ubuntu:22.04

MAINTAINER Guillaume Poirier-Morency <guillaumepoiriermorency@gmail.com>

RUN apt-get update && apt-get install -y \
    libfcgi-dev                          \
    libglib2.0-dev                       \
    libsoup2.4-dev                       \
    libssl-dev                           \
    ninja-build                          \
    meson                                \
    valac                                \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install meson

WORKDIR /valum
ADD . .

RUN mkdir build && meson --prefix=/usr --buildtype=release . build && ninja -C build && ninja -C build install
# -rpath dosen't work on 22.04 (see https://github.com/valum-framework/valum/issues/224)
ENV VSGI_SERVER_PATH=/usr/lib/x86_64-linux-gnu/vsgi-0.4/servers
