#!/bin/sh

mkdir -p "${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi"

install -m 0644                                \
    "${MESON_BUILD_ROOT}/src/vsgi/vsgi-0.3.vapi"   \
    "${MESON_BUILD_ROOT}/src/valum/valum-0.3.vapi" \
    "${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi"
