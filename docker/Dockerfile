FROM freebsd/freebsd:14.2-RELEASE

ENV ASSUME_ALWAYS_YES=yes
ENV AERO_BUILD_CONTAINER=1

RUN pkg update && pkg install -y \
    bash \
    swift \
    gtk4 \
    gtk4-layer-shell \
    pkgconf \
    weston \
    wayland \
    pipewire \
    wireplumber \
    mesa-drivers \
    drm-kmod \
    wpa_supplicant \
    sudo \
    curl \
    git \
    xorriso \
    cdrtools \
    mtools \
    gpart \
    ntfs-3g \
    thunar \
    foot \
    inter-font \
    freebsd-release \
    bsdinstall \
    gmake \
    ca_root_nss

COPY docker/entrypoint.sh /usr/local/bin/aero-entrypoint.sh
RUN chmod +x /usr/local/bin/aero-entrypoint.sh

WORKDIR /aero
ENTRYPOINT ["/usr/local/bin/aero-entrypoint.sh"]
