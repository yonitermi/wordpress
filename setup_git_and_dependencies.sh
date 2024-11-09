#!/bin/bash

# Update the system package list
echo "Updating system packages..."
sudo apt update

# Install MySQL client for database backups
echo "Installing MySQL client..."
sudo apt install mysql-client -y

# Install tar for backing up the WordPress folder
echo "Installing tar utility..."
sudo apt install tar -y

# Install Git for version control
echo "Installing Git..."
sudo apt install git -y

# Install Python MySQL libraries (for Ansible's mysql_db module)
echo "Installing Python MySQL libraries..."
sudo apt install python3-mysqldb -y  # or use PyMySQL if needed

# Confirm installation of all components
echo "All required dependencies are installed!"

# (Optional) Test Git installation
git --version

