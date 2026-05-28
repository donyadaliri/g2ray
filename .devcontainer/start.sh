#!/bin/bash
# g2ray start script — Real Verification Edition

# 1. Clean up previous sessions and old signals
tmux kill-session -t g2ray 2>/dev/null || true
rm -f /tmp/server_ready

# 2. Run Xray core in background (Auto-Restart)
tmux new-session -d -s g2ray "bash -c 'while true; do xray run -c /etc/xray/g2ray.json > /tmp/xray.log 2>&1; sleep 2; done'"

# 3. Quality control loop: Public port + Stability test + Send READY signal
tmux new-window -t g2ray -n monitor "bash -c '
  # a) Wait until Xray successfully binds port 443
  while ! timeout 1 bash -c \"cat < /dev/null > /dev/tcp/127.0.0.1/443\" 2>/dev/null; do 
      sleep 1 
  done
  
  # b) Continuous attempt to make the port public on GitHub network
  until gh codespace ports visibility 443:public -c \$CODESPACE_NAME 2>/dev/null; do 
      sleep 2 
  done
  
  # c) Create actual readiness signal file (everything is smooth and connected now)
  echo \"READY\" > /tmp/server_ready   # <---- این خط را اضافه کن
  
  # d) Start keepalive loop to keep the container alive
  while true; do 
      curl -s --max-time 5 https://github.com/ -o /dev/null
      sleep 180
  done
'"
