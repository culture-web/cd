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
  echo "  MINIO_ROOT_USER=minioadmin"
  echo "  MINIO_ROOT_PASSWORD=minioadmin"
  echo "  MINIO_ACCESS_KEY=minioadmin"
  echo "  MINIO_SECRET_KEY=minioadmin"
  echo "  MINIO_ENDPOINT=minio"
  echo "  MINIO_PORT=9000"
  echo "  MINIO_BUCKET=knowledge-base"
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