FROM php:8.2-cli

RUN docker-php-ext-install pdo pdo_mysql

# Install Supervisor
RUN apt-get update && \
    apt-get install -y supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy Supervisor configuration files into the container
COPY supervisord.conf /etc/supervisor/supervisord.conf

WORKDIR /var/www/html

# Command to start Supervisor
CMD ["supervisord", "-n" , "-c", "/etc/supervisor/supervisord.conf"]