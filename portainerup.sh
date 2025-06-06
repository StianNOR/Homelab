#!/bin/bash

set -e

echo "🔄 Stopping Portainer..."
docker stop portainer || true

echo "🧹 Removing old Portainer container..."
docker rm portainer || true

echo "🐳 Pulling latest Portainer image..."
docker pull portainer/portainer-ce:latest

echo "🚀 Starting updated Portainer container..."
docker run -d \
  -p 8000:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

echo "✅ Portainer updated and running!"

