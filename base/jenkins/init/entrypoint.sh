#!/bin/bash
set -e

# Copy JCasC YAML files into a shared volume
# Jenkins will load these via Helm chart configuration

echo "[INFO] Copying JCasC config files..."
mkdir -p /workspace/jcasc
cp -v /jcasc/*.yaml /workspace/jcasc/

echo "[INFO] Init complete."
