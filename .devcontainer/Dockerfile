FROM debian:bookworm-slim

COPY .devcontainer/config.json /etc/xray/g2ray.json
COPY .devcontainer/show-link.sh /usr/local/bin/show-link.sh
COPY .devcontainer/start.sh /usr/local/bin/start.sh

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash curl wget unzip ca-certificates openssl uuid-runtime tmux \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/xray \
    && echo "[Node-Alpha] Downloading Xray..." \
    && curl -sL "https://github.com/XTLS/Xray-core/releases/download/v26.3.27/Xray-linux-64.zip" -o /tmp/xray.zip \
    && unzip -q /tmp/xray.zip -d /tmp/ \
    && install -m 755 /tmp/xray /usr/local/bin/xray \
    && echo "[Node-Alpha] Downloading GeoData..." \
    && curl -sL "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" -o /usr/local/bin/geoip.dat \
    && curl -sL "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" -o /usr/local/bin/geosite.dat \
    && rm -rf /tmp/xray* \
    && chmod +x /usr/local/bin/show-link.sh \
    && chmod +x /usr/local/bin/start.sh

EXPOSE 443
