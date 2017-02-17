#!/bin/sh

mkdir -p "${DESTDIR}/${MESON_INSTALL_PREFIX}/include/valum-0.4"
mkdir -p "${DESTDIR}/${MESON_INSTALL_PREFIX}/share/vala/vapi"

install "${MESON_BUILD_ROOT}/src/valum/valum.h" "${MESON_INSTALL_DESTDIR_PREFIX}/include/valum-0.4"
install "${MESON_BUILD_ROOT}/src/valum/valum-0.4.vapi" "${MESON_INSTALL_DESTDIR_PREFIX}/share/vala/vapi"
install "${MESON_SOURCE_ROOT}/src/valum/valum-0.4.deps" "${MESON_INSTALL_DESTDIR_PREFIX}/share/vala/vapi"
