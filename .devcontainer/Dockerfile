FROM debian:bookworm-slim

# Install dependencies and Xray core
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip bash tmux ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip \
    && mkdir -p /etc/xray

# Copy scripts and config from the correct paths (Updated for inside .devcontainer)
COPY .devcontainer/config.json /etc/xray/g2ray.json
COPY .devcontainer/start.sh /usr/local/bin/start.sh
COPY .devcontainer/show-link.sh /usr/local/bin/show-link.sh

# Set execution permissions
RUN chmod +x /usr/local/bin/start.sh /usr/local/bin/show-link.sh
