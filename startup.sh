#!/bin/bash

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
  echo "  MINIO_ACCESS_KEY=xxx_minio_access_key"
  echo "  MINIO_SECRET_KEY=xxx_minio_secret_key"
  echo "  MINIO_ENDPOINT=xxx_minio_endpoint"
  echo "  MINIO_PORT=xxx_minio_port"
  echo "  MINIO_BUCKET=xxx_minio_bucket"
  echo "  MINIO_USE_SSL=false"
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

# Stop running containers
sudo docker compose stop

# Remove stopped containers
sudo docker compose rm -f

# git pull latest changes
# UPDATE: SKIP RUNNING THIS COMMAND IN VM CD DIRECTORY TO AVOID OVERWRITING LOCAL CHANGES
# git pull https://github.com/culture-web/cd.git

# Pull fresh images
sudo docker compose --env-file .env.production pull


# Start Docker Compose services in detached mode with .env.production file
sudo docker compose --env-file .env.production up -d