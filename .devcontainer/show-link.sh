#!/bin/bash
CONFIG="/etc/xray/g2ray.json"
UUID=$(grep -o '"id": *"[^"]*"' "$CONFIG" | head -1 | grep -o '"[^"]*"$' | tr -d '"')
if [ -z "$UUID" ]; then echo "[Node-Alpha] UUID not found."; exit 1; fi
SNI="${CODESPACE_NAME}-443.app.github.dev"
IPS=("94.130.50.12" "50.7.5.83" "63.141.252.203")

if [ ! -f /tmp/server_ready ]; then
    echo -n "⏳ [Node-Alpha] Starting core and testing network stability... Please wait"
    TIMEOUT=40
    while [ ! -f /tmp/server_ready ] && [ $TIMEOUT -gt 0 ]; do
        sleep 1
        ((TIMEOUT--))
        echo -n "."
    done
    echo ""
    
    if [ $TIMEOUT -le 0 ]; then
        echo "❌ [Error] Timeout reached! Server or port 443 did not fully activate."
        exit 1
    fi
fi

echo ""
echo "====================================================="
echo " ✅ Server is fully active, smooth, and ready!       "
echo "====================================================="

for IP in "${IPS[@]}"; do
    LINK="vless://${UUID}@${IP}:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#Node-Alpha-[${IP}]"
    echo " 🌐 IP: $IP"
    echo " $LINK"
    echo "-----------------------------------------------------"
done
echo ""
