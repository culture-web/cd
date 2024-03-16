#!/bin/bash

cd /home/ubuntu/cd

# Stop running containers
docker-compose stop

# Remove stopped containers
docker-compose rm -f

# git pull latest changes
git pull https://github.com/culture-web/cd.git

# Pull fresh images
docker-compose pull

# Start Docker Compose services in detached mode
docker-compose up