#!/bin/bash

# Define the path to your SSL certificate and key
CERT_PATH="/home/nouser/yoni-wordpress/ssl/cert.pem"
KEY_PATH="/home/nouser/yoni-wordpress/ssl/key.pem"

# Check if SSL certificate is close to expiring (less than 30 days remaining)
EXPIRATION_DATE=$(openssl x509 -enddate -noout -in "$CERT_PATH" | cut -d= -f2)
EXPIRATION_SEC=$(date -d "$EXPIRATION_DATE" +%s)
CURRENT_DATE=$(date +%s)
DAYS_REMAINING=$(( ($EXPIRATION_SEC - $CURRENT_DATE) / 86400 ))

# Renew the certificate if less than 30 days remaining
if [ "$DAYS_REMAINING" -lt 30 ]; then
    echo "SSL certificate is expiring in $DAYS_REMAINING days. Renewing..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$KEY_PATH" -out "$CERT_PATH" -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/CN=localhost"
    echo "SSL certificate renewed successfully."
else
    echo "SSL certificate is valid for $DAYS_REMAINING more days. No renewal needed."
fi

