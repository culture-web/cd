#!/bin/bash

# Stop immediately if any command fails
set -e

cd "$(dirname "$0")"

# Check if .env.production file exists
if [ ! -f .env.production ]; then
  echo "ERROR: .env.production file not found!"
  echo "Please create .env.production with database and MinIO credentials:"
  echo ""
  echo "Example:"
  echo "  LOCAL_DB_USER=xxx_db_user"
  echo "  LOCAL_DB_PASSWORD=xxx_secure_password"
  echo "  LOCAL_DB_NAME=xxx_db_name"
  echo "  MINIO_ROOT_USER=xxx_minio_user"
  echo "  MINIO_ROOT_PASSWORD=xxx_secure_password"
  echo ""
  exit 1
fi

# Check if init folder exists
if [ ! -d ./init ]; then
  echo "ERROR: init folder not found!"
  echo "Please ensure ./init/local_rag_setup.sql exists"
  echo ""
  exit 1
fi

# Ensure deployment is running from the develop branch
if [ "$(git branch --show-current)" != "develop" ]; then
  echo "ERROR: Repository is not on the develop branch."
  exit 1
fi

# Prevent Git pull from conflicting with local tracked changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: Repository contains uncommitted tracked changes."
  echo "Commit, stash, or discard them before deploying."
  git status --short
  exit 1
fi

# Update deployment files from GitHub before touching running containers
echo "Updating deployment files from origin/develop..."
git pull --ff-only origin develop

# Pre-flight disk space check (warn and prune dangling resources if under 3GB free)
AVAILABLE_KB=$(df -k . | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_KB" -lt 3145728 ]; then
  echo "WARNING: Low disk space detected (< 3GB free). Cleaning up dangling Docker resources before pull..."
  sudo docker image prune -f || true
  sudo docker builder prune -f || true
fi

# Validate the updated Docker Compose configuration
echo "Validating Docker Compose configuration..."
sudo docker compose --env-file .env.production config --quiet

# Download new images while the existing containers remain running
echo "Pulling Docker images..."
sudo docker compose --env-file .env.production pull --ignore-pull-failures

# Stop running containers
echo "Stopping existing containers..."
sudo docker compose --env-file .env.production stop

# Remove stopped containers
echo "Removing stopped containers..."
sudo docker compose --env-file .env.production rm -f

# Start Docker Compose services in detached mode
echo "Starting containers..."
sudo docker compose --env-file .env.production up -d

# Clean up superseded Docker images and build cache to prevent disk accumulation
echo "Pruning superseded Docker images and build cache..."
sudo docker image prune -f || true
sudo docker builder prune -f || true

echo "Deployment completed successfully."
sudo docker compose --env-file .env.production ps

echo ""
echo "Current disk usage:"
df -h .
