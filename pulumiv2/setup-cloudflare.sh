#!/bin/bash

echo "=== Cloudflare SSL and Load Balancer Setup ==="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from example.env..."
    cp example.env .env
    echo "Please edit .env file with your Cloudflare credentials"
    echo ""
fi

# Source the .env file if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check required environment variables
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "ERROR: CLOUDFLARE_API_TOKEN not set in .env file"
    exit 1
fi

# Set Pulumi configuration
echo "Setting Pulumi configuration..."

if [ ! -z "$CLOUDFLARE_ZONE_ID" ]; then
    pulumi config set cloudflareZoneId "$CLOUDFLARE_ZONE_ID"
fi

if [ ! -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    pulumi config set cloudflareAccountId "$CLOUDFLARE_ACCOUNT_ID"
fi

if [ ! -z "$DOMAIN" ]; then
    pulumi config set domain "$DOMAIN"
fi

if [ ! -z "$NOTIFICATION_EMAIL" ]; then
    pulumi config set notificationEmail "$NOTIFICATION_EMAIL"
fi

echo ""
echo "Configuration complete!"
echo ""
echo "Next steps:"
echo "1. Ensure your VM IP (192.3.231.145) is correct in index.ts"
echo "2. Run 'pulumi up' to deploy the infrastructure"
echo "3. The Origin certificate will be saved to ./ssl/origin.crt"
echo "4. Configure your VM firewall to allow traffic from Cloudflare IPs only"
echo ""
echo "Cloudflare IP ranges: https://www.cloudflare.com/ips/"