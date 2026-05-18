#!/bin/bash
# Node-Alpha Start Script

tmux kill-session -t g2ray 2>/dev/null || true
rm -f /tmp/server_ready

tmux new-session -d -s g2ray "bash -c 'while true; do xray run -c /etc/xray/g2ray.json > /tmp/xray.log 2>&1; sleep 2; done'"

tmux new-window -t g2ray -n monitor "bash -c '
  while ! timeout 1 bash -c \"cat < /dev/null > /dev/tcp/127.0.0.1/443\" 2>/dev/null; do 
      sleep 1 
  done
  
  until gh codespace ports visibility 443:public -c ${CODESPACE_NAME} 2>/dev/null; do 
      sleep 2 
  done
  
  echo \"READY\" > /tmp/server_ready
  
  while true; do 
      curl -s --max-time 5 https://github.com/ -o /dev/null
      sleep 180
  done
'"
