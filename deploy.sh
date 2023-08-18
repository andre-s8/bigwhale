#!/bin/bash

git reset --hard

git fetch && git pull

if ! docker info || systemctl status docker > /dev/null 2>&1 ; then
    echo "Docker is not running, failed to deploy Exiting..."
    exit 1
fi

# List of container names to check and start if not running
CONTAINERS=("application" "mysql" "redis-database" "adminer" "nginx-webserver" "supervisor")

# Function to check if a container is running
is_container_running() {
    local container_name="$1"
    docker ps -q --filter "name=${container_name}" | grep -q .
}

# Function to start a container
start_container() {
    local container_name="$1"
    if ! is_container_running "${container_name}" ; then
        echo "Starting container '${container_name}'..."
        docker start "${container_name}"
    fi
}

restart_container() {
    local container_name="$1"
    docker restart "${container_name}"
    echo -e "Container ${container_name} has been restarted"
}
 
# Start containers if not running and wait for them to be up
for container in "${CONTAINERS[@]}"; do
    start_container "${container}"
done

# Wait for containers to be up
for container in "${CONTAINERS[@]}"; do
    while ! is_container_running "${container}" ; do
        echo "Waiting for container '${container}' to be up..."
        sleep 1
    done
    echo "Container '${container}' is up."
done

docker compose exec application php artisan down

docker compose exec application php artisan auth:clear-resets

docker compose exec application php artisan optimize:clear

docker compose exec application php artisan migrate --seed --force

docker compose exec application php artisan storage:link

docker compose exec application php artisan optimize

docker compose exec application php artisan up

# restart all the conatiners
for container in "${CONTAINERS[@]}"; do
    restart_container "${container}"
done

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