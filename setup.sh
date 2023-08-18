#!/bin/bash
set -e

# Generate a random 20-character password
generate_password() {
    password=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
    echo "$password"
}

# Validate input string
validate_input() {
    input="$1"
    if [[ ! "$input" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 1  # Invalid input
    fi
    return 0  # Valid input
}

# Prompt user for valid input
prompt_for_valid_input() {
    prompt="$1"
    input=""
    while true; do
        read -r -p "$prompt" input
        if validate_input "$input"; then
            break
        else
            echo "Invalid input. Please use only letters, numbers, or underscores."
        fi
    done
}




# Check if .env file exists
if [ -f .env ]; then
    echo -e $'\e[1;33mEnviornment already setup.\e[0m '

    # Prompt user to continue
    read -r -p "Do you want to restart? (this will delete the .env) (y/n): " choice

    if [ "$choice" == "y" ] || [ "$choice" == "Y" ]; then
        docker volume prune
        docker-compose down --volumes
        rm .env 
        echo -e $'\e[1;32mThe .env file has been deleted.$\e[0m'
    else
        echo "Operation canceled."
    fi
fi

# Prompt user to choose environment type
PS3=$'\e[1;32mSelect the environment type:\e[0m ' 
options=( $'\e[1;31mproduction\e[0m' $'\e[1;35mstaging\e[0m' $'\e[1;34mdevelopment\e[0m')

select opt in "${options[@]}"; do
    case $opt in
        $'\e[1;31mproduction\e[0m')
            environment="production"
            app_debug="false"
            cache_driver="redis"
            break
            ;;
        $'\e[1;35mstaging\e[0m')
            environment="staging"
            app_debug="true"
            cache_driver="redis"
            break
            ;;
        $'\e[1;34mdevelopment\e[0m')
            environment="local"
            app_debug="true"
            cache_driver="redis"
            break
            ;;
        *)
            echo "Invalid option. Please select a valid option."
            ;;
    esac
done

echo -e "Using $environment"

# Prompt user for database name
prompt_for_valid_input "Enter the database name for $environment environment: "
db_name="$input"

# Prompt user for database user
prompt_for_valid_input "Enter the database user for $environment environment: "
db_user="$input"

# generate a password for the database
db_password=$(generate_password)


# Check if a file does not exist
if [ ! -e ".env" ]; then
    echo "Creating .env file for the $environment"
    touch .env
fi

# lets just have the app name as Big Whale
 prompt_for_valid_input "Enter the app name for $environment environment: ";
 app_name="$input"

# Check if .env file exists
if [ -f .env ]; then

    echo "APP_NAME=$app_name" >> .env
    echo "APP_ENV=$environment" >> .env
    echo "APP_KEY=" >> .env
    echo "APP_DEBUG=$app_debug" >> .env
    echo "APP_URL=http://application:9000" >> .env
    echo "LOG_CHANNEL=stack" >> .env
    echo "LOG_DEPRECATIONS_CHANNEL=null" >> .env
    echo "LOG_LEVEL=debug" >> .env
    echo "DB_CONNECTION=mysql" >> .env
    echo "DB_HOST=mysql" >> .env
    echo "DB_PORT=3306" >> .env
    echo "DB_DATABASE=$db_name" >> .env
    echo "DB_USERNAME=$db_user" >> .env
    echo "DB_PASSWORD=$db_password" >> .env
    echo "BROADCAST_DRIVER=log" >> .env
    echo "CACHE_DRIVER=$cache_driver" >> .env
    echo "FILESYSTEM_DISK=public" >> .env
    echo "QUEUE_CONNECTION=database" >> .env
    echo "SESSION_DRIVER=file" >> .env
    echo "SESSION_LIFETIME=120" >> .env
    echo "MEMCACHED_HOST=127.0.0.1" >> .env
    echo "REDIS_HOST=redis" >> .env
    echo "REDIS_PASSWORD=null" >> .env
    echo "REDIS_PORT=6379" >> .env
    echo "MAIL_MAILER=smtp" >> .env
    echo "MAIL_HOST=mailpit" >> .env
    echo "MAIL_PORT=1025" >> .env
    echo "MAIL_USERNAME=null" >> .env
    echo "MAIL_PASSWORD=null" >> .env
    echo "MAIL_ENCRYPTION=null" >> .env
    echo 'MAIL_FROM_ADDRESS="hello@example.com"' >> .env
    echo "MAIL_FROM_NAME=$app_name" >> .env
    echo "AWS_ACCESS_KEY_ID=" >> .env
    echo "AWS_SECRET_ACCESS_KEY=" >> .env
    echo "AWS_DEFAULT_REGION=us-east-1" >> .env
    echo "AWS_BUCKET=" >> .env
    echo "AWS_USE_PATH_STYLE_ENDPOINT=false" >> .env
    echo "PUSHER_APP_ID=" >> .env
    echo "PUSHER_APP_KEY=" >> .env
    echo "PUSHER_APP_SECRET=" >> .env
    echo "PUSHER_HOST=" >> .env
    echo "PUSHER_PORT=443" >> .env
    echo "PUSHER_SCHEME=https" >> .env
    echo "PUSHER_APP_CLUSTER=mt1" >> .env
    echo "REDIS_CLIENT=predis" >> .env
    echo "MYSQL_DATABASE=$db_name" >> .env
    echo "MYSQL_USER=$db_user" >> .env
    echo "MYSQL_PASSWORD=$db_password" >> .env
    echo "MYSQL_ROOT_PASSWORD=$db_password" >> .env
    echo "Updating the enviornment config files....."
else
    echo "The .env file does not exist."
fi

docker compose up --build -d 

# Define the message and URL
message="Application is done and accessible at:"
url="http://localhost:8081"


GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}"
echo "   ___                      _      _       "
echo "  / __\___  _ __ ___  _ __ | | ___| |_ ___ "
echo " / /  / _ \| '_ \` _ \| '_ \| |/ _ \ __/ _ \\"
echo "/ /__| (_) | | | | | | |_) | |  __/ ||  __/"
echo "\____/\___/|_| |_| |_| .__/|_|\___|\__\___|"
echo "                     |_|                   "
echo -e "${NC}"


# Print the message and URL
echo "$message"
echo "$url"
echo "Environment: $environment"