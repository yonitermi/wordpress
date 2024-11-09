#!/bin/bash

# Load environment variables from the .env file
source /home/nouser/yoni-wordpress/.env

# Directories to store backups
backup_dir="/home/nouser/backups"
mysql_backup_dir="$backup_dir/mysql_bu"
wordpress_backup_dir="$backup_dir/wordpress_bu"

# Create directories if they don't exist
mkdir -p "$mysql_backup_dir"
mkdir -p "$wordpress_backup_dir"

# Date format for backup files
date=$(date +"%Y-%m-%d")

# Backup MySQL database
echo "Backing up MySQL database..."
docker exec yoni-wordpress-mysql-1 mysqldump -u $MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASE > "$mysql_backup_dir/db-backup-$date.sql"

# Backup WordPress volume
echo "Backing up WordPress volume..."
docker run --rm --volumes-from yoni-wordpress-wordpress-1 -v "$wordpress_backup_dir:/backup" ubuntu tar cvf /backup/wordpress-backup-$date.tar /var/www/html

echo "Weekly tasks completed."

