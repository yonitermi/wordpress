#!/bin/bash

# Load environment variables from the .env file
export $(grep -v '^#' /home/nouser/yoni-wordpress/.env | xargs)

# Ask user for the backup date
echo "Enter the date of the backup you want to restore (format: YYYY-MM-DD):"
read backup_date

# Paths to backup files based on user input
mysql_backup_file="/home/nouser/backups/mysql_bu/db-backup-${backup_date}.sql"
wordpress_backup_file="/home/nouser/backups/wordpress_bu/wordpress-backup-${backup_date}.tar"

# Check if the backup files exist
if [ ! -f "$mysql_backup_file" ]; then
    echo "MySQL backup for date ${backup_date} not found: $mysql_backup_file"
    exit 1
fi

if [ ! -f "$wordpress_backup_file" ]; then
    echo "WordPress backup for date ${backup_date} not found: $wordpress_backup_file"
    exit 1
fi

# Print message
echo "Checking container status..."

# Check if containers are running
mysql_container=$(docker ps --filter name=yoni-wordpress-mysql-1 --format "{{.Names}}")
wordpress_container=$(docker ps --filter name=yoni-wordpress-wordpress-1 --format "{{.Names}}")

if [ -z "$mysql_container" ] || [ -z "$wordpress_container" ]; then
    echo "Containers are not running. Starting containers..."
    docker-compose -f /home/nouser/yoni-wordpress/docker-compose.yml up -d
    sleep 30  # Wait for containers to start
else
    echo "Containers are already running. Restarting them..."
    docker-compose -f /home/nouser/yoni-wordpress/docker-compose.yml restart
    sleep 10  # Give the containers time to restart
fi

# Step 1: Restore the MySQL database
echo "Restoring MySQL database..."
docker exec -i yoni-wordpress-mysql-1 mysql -u root -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} < "$mysql_backup_file"
if [ $? -eq 0 ]; then
    echo "MySQL database restored successfully!"
else
    echo "Error restoring MySQL database."
    exit 1
fi

# Step 2: Restore WordPress files
echo "Restoring WordPress files..."

# Copy the tar backup file into the WordPress container
docker cp "$wordpress_backup_file" yoni-wordpress-wordpress-1:/tmp/wordpress-backup.tar

# Extract the backup inside the container's /var/www/html directory
docker exec -i yoni-wordpress-wordpress-1 tar -xvf /tmp/wordpress-backup.tar -C /var/www/html/
if [ $? -eq 0 ]; then
    echo "WordPress files restored successfully!"
else
    echo "Error restoring WordPress files."
    exit 1
fi

# Step 3: Restart containers to ensure everything works properly after restoration
echo "Restarting containers..."
docker-compose -f /home/nouser/yoni-wordpress/docker-compose.yml down
docker-compose -f /home/nouser/yoni-wordpress/docker-compose.yml up -d
if [ $? -eq 0 ]; then
    echo "Containers restarted successfully!"
else
    echo "Error restarting containers."
    exit 1
fi

echo "Restoration process completed!"

