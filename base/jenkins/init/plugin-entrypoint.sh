#!/bin/sh

echo "[plugin-init] Installing plugins from plugins.txt..."

# Set the plugin directory for jenkins-plugin-cli
export JENKINS_PLUGIN_DIR=/workspace/plugins

jenkins-plugin-cli \
  --plugin-file /workspace/config/plugins.txt

echo "[plugin-init] Plugin installation complete."
