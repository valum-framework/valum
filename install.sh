#!/bin/sh

mkdir -p "${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi"

install -m 0644                                \
    "${MESON_BUILD_ROOT}/src/vsgi/vsgi.vapi"   \
    "${MESON_BUILD_ROOT}/src/valum/valum.vapi" \
    "${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi"
