ARG BUILD_FROM=debian:12.7-slim
# hadolint ignore=DL3006
FROM ${BUILD_FROM}


SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_ARCH=amd64
ARG BASHIO_VERSION="v0.16.2"
ARG S6_OVERLAY_VERSION="3.2.0.2"
ARG TEMPIO_VERSION="2021.09.0"
RUN \
    apt-get update \
    \
    && apt-get install -y --no-install-recommends \
        bash=5.2.15-2+b7 \
        ca-certificates=20230311 \
        curl=7.88.1-10+deb12u7 \
        jq=1.6-2.1 \
        tzdata=2024a-0+deb12u1 \
        xz-utils=5.4.1-0.2 \
    \
    && c_rehash \
    \
    && S6_ARCH="${BUILD_ARCH}" \
    && if [ "${BUILD_ARCH}" = "i386" ]; then S6_ARCH="i686"; \
    elif [ "${BUILD_ARCH}" = "amd64" ]; then S6_ARCH="x86_64"; \
    elif [ "${BUILD_ARCH}" = "armv7" ]; then S6_ARCH="arm"; fi \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" \
        | tar -C / -Jxpf - \
    \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && curl -J -L -o /tmp/bashio.tar.gz \
        "https://github.com/hassio-addons/bashio/archive/${BASHIO_VERSION}.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf \
        /tmp/bashio.tar.gz \
        --strip 1 -C /tmp/bashio \
    \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    \
    && curl -L -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/tempio \
    \
    && apt-get purge -y --auto-remove \
        xz-utils \
    && apt-get clean \
    && rm -fr \
        /tmp/* \
        /var/{cache,log}/* \
        /var/lib/apt/lists/*

COPY s6-overlay /package/admin/s6-overlay-${S6_OVERLAY_VERSION}/


RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections
RUN apt-get update
RUN apt-get dist-upgrade -qy
RUN apt-get install -qy --no-install-recommends systemd systemd-sysv corosync-qnetd  openssh-server 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /var/log/alternatives.log /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log
RUN mkdir -p /run/sshd \
	&& chmod 0755 /run/sshd \
	&& chown root:root /run/sshd
RUN chown -R coroqnetd:coroqnetd /etc/corosync/qnetd /var/run/corosync-qnetd
RUN systemctl mask -- dev-hugepages.mount sys-fs-fuse-connections.mount
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id


COPY rootfs /

RUN chmod +x /App/run.sh


FROM debian:bookworm-slim
COPY --from=0 / /
ENV container docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]
EXPOSE 22 5403
CMD ["/App/run.sh"]

# Build arugments
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION
ARG BUILD_REPOSITORY