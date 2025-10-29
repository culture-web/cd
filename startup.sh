#!/bin/bash

cd /home/ubuntu/cd

# Stop running containers
sudo docker compose stop

# Remove stopped containers
sudo docker compose rm -f

# git pull latest changes
# UPDATE: SKIP RUNNING THIS COMMAND IN VM CD DIRECTORY TO AVOID OVERWRITING LOCAL CHANGES
# git pull https://github.com/culture-web/cd.git

# Pull fresh images
sudo docker compose pull

# Start Docker Compose services in detached mode
sudo docker compose up -d
