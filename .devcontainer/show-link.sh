#!/bin/bash

CONFIG="/etc/xray/g2ray.json"
UUID=$(grep -o '"id": *"[^"]*"' "$CONFIG" | head -1 | grep -o '"[^"]*"$' | tr -d '"')
if [ -z "$UUID" ]; then 
    echo "[g2ray] UUID not found."; 
    exit 1; 
fi

SNI="${CODESPACE_NAME}-443.app.github.dev"

test_endpoint() {
    local address=$1
    timeout 3 bash -c "echo >/dev/tcp/$address/443" 2>/dev/null
    return $?
}

echo "[g2ray] Resolving actual Codespace IPs..."

RESPONSE=$(curl -s "https://dns.google/resolve?name=${SNI}&type=A")
IPS=$(echo "$RESPONSE" | grep -o '"data":"[0-9.]*"' | cut -d'"' -f4 | head -5)

if [ -z "$IPS" ]; then
    if command -v dig &> /dev/null; then
        IPS=$(dig +short "$SNI" | grep -E '^[0-9.]+$' | head -5)
    fi
fi

POSSIBLE_ENDPOINTS=("$SNI" ${IPS})

WORKING_ENDPOINTS=()
echo "[g2ray] Testing endpoints (may take a few seconds)..."
for ENDPOINT in "${POSSIBLE_ENDPOINTS[@]}"; do
    echo -n "  Testing $ENDPOINT ... "
    if test_endpoint "$ENDPOINT"; then
        echo "✅ WORKING"
        WORKING_ENDPOINTS+=("$ENDPOINT")
    else
        echo "❌ FAILED"
    fi
done

if [ ! -f /tmp/server_ready ]; then
    echo -n "⏳ Waiting for server to be fully ready..."
    TIMEOUT=40
    while [ ! -f /tmp/server_ready ] && [ $TIMEOUT -gt 0 ]; do
        sleep 1
        ((TIMEOUT--))
        echo -n "."
    done
    echo ""
fi

echo ""
echo "====================================================="
if [ ${#WORKING_ENDPOINTS[@]} -gt 0 ]; then
    echo " ✅ Server is active! Found ${#WORKING_ENDPOINTS[@]} working endpoint(s)"
    echo "====================================================="
    echo ""
    for ENDPOINT in "${WORKING_ENDPOINTS[@]}"; do
        if [[ "$ENDPOINT" == *".app.github.dev" ]]; then
            LINK="vless://${UUID}@${ENDPOINT}:443?encryption=none&security=tls&sni=${ENDPOINT}&host=${ENDPOINT}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#${ENDPOINT}"
            echo " 🌐 DOMAIN (Best Speed):"
        else
            LINK="vless://${UUID}@${ENDPOINT}:443?encryption=none&security=tls&sni=${SNI}&host=${SNI}&fp=chrome&allowInsecure=1&type=xhttp&mode=packet-up&path=%2F#${SNI}-[${ENDPOINT}]"
            echo " 🌐 IP: $ENDPOINT"
        fi
        echo " $LINK"
        echo "-----------------------------------------------------"
    done
else
    echo " ❌ No working endpoints found!                      "
    echo "====================================================="
    echo ""
    echo "Possible reasons:"
    echo "  1. Port 443 is not public yet (check GitHub Codespace ports)"
    echo "  2. Xray is not running properly (run: tmux attach -t g2ray)"
    echo "  3. Network issue"
    echo ""
    echo "💡 Fallback: Create Cloudflare Tunnel:"
    echo "   cloudflared tunnel --url http://localhost:443"
    echo "   Then use the returned domain in your config."
fi
echo ""
