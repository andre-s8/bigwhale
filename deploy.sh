#!/bin/bash

git reset --hard

git fetch && git pull

if ! docker info || systemctl status docker > /dev/null 2>&1 ; then
    echo "Docker is not running, failed to deploy Exiting..."
    exit 1
fi

# Name of the container you want to check
CONTAINER_NAME="application"

# Check if the container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$" ; then
    docker compose up --build -d
fi

docker compose exec application php artisan down

docker compose exec application php auth:clear-resets

docker compose exec application php optimize:clear

docker compose exec application php artisan migrate --seed --force

docker compose exec application php storage:link

docker compose exec application php optimize

docker compose exec application php artisan up

# Define the blue color escape code
BLUE="\033[34m"
RESET="\033[0m"

# Echo the text in blue
echo -e "${BLUE}  _____             _                      _   _"
echo " |  __ \\           | |                    | | | |"
echo " | |  | | ___ _ __ | | ___  _   _  ___  __| | | |"
echo " | |  | |/ _ \\ '_ \\| |/ _ \\| | | |/ _ \\/ _\` | | |"
echo " | |__| |  __/ |_) | | (_) | |_| |  __/ (_| | |_|"
echo " |_____/ \\___| .__/|_|\\___/ \\__, |\\___|\\__,_| (_)"
echo "             | |             __/ |"
echo -e "             |_|            |___/   ${RESET}"