#!/bin/sh

mkdir -p "${DESTDIR}/${MESON_INSTALL_PREFIX}/include/vsgi-0.3"
mkdir -p "${DESTDIR}/${MESON_INSTALL_PREFIX}/share/vala/vapi"

install "${MESON_BUILD_ROOT}/src/vsgi/vsgi.h" "${MESON_INSTALL_DESTDIR_PREFIX}/include/vsgi-0.3"
install "${MESON_BUILD_ROOT}/src/vsgi/vsgi-0.3.vapi" "${MESON_INSTALL_DESTDIR_PREFIX}/share/vala/vapi"
install "${MESON_SOURCE_ROOT}/src/vsgi/vsgi-0.3.deps" "${MESON_INSTALL_DESTDIR_PREFIX}/share/vala/vapi"
