# Cloudflare SSL and Load Balancer Setup

This Pulumi configuration sets up Cloudflare SSL certificates and load balancing for your self-hosted development platform.

## Features

- **SSL/TLS Encryption**: End-to-end encryption using Cloudflare Origin CA certificates
- **Load Balancer**: Cloudflare Load Balancer for high availability
- **Health Monitoring**: Automatic health checks for your VM
- **DDoS Protection**: Cloudflare's built-in DDoS protection
- **Session Affinity**: Cookie-based session persistence

## Prerequisites

1. A Cloudflare account with a registered domain
2. Cloudflare API Token with permissions for:
   - Zone:DNS:Edit
   - Zone:SSL and Certificates:Edit
   - Account:Load Balancing:Edit
3. Your VM's public IP address (currently set to 192.3.231.145)

## Setup Instructions

### 1. Configure Environment

Copy the example environment file and edit it:

```bash
cp example.env .env
# Edit .env with your Cloudflare credentials
```

### 2. Run Setup Script

```bash
./setup-cloudflare.sh
```

This script will:
- Check for required environment variables
- Set Pulumi configuration values
- Prepare the environment for deployment

### 3. Deploy Infrastructure

```bash
pulumi up
```

This will:
- Generate an Origin CA certificate (valid for 15 years)
- Create a load balancer with health monitoring
- Deploy an Nginx container for SSL termination
- Configure all necessary Cloudflare resources

### 4. Post-Deployment Steps

1. **Configure VM Firewall**: Restrict access to Cloudflare IPs only
   ```bash
   # Example for UFW
   sudo ufw allow from 173.245.48.0/20
   sudo ufw allow from 103.21.244.0/22
   # ... add all Cloudflare ranges from https://www.cloudflare.com/ips/
   ```

2. **Update DNS**: Ensure your domain points to Cloudflare (orange cloud enabled)

3. **Test SSL**: Visit https://patio.yourdomain.com to verify SSL is working

## Architecture

```
Internet → Cloudflare → Load Balancer → Your VM → Nginx (SSL) → Portainer
                ↓
            Origin CA
           Certificate
```

## Configuration Details

### Load Balancer
- **Health Check**: HTTPS GET /health every 60 seconds
- **Session Affinity**: Cookie-based, 30-minute TTL
- **Failover**: Automatic with configurable pools

### SSL Certificate
- **Type**: Cloudflare Origin CA
- **Validity**: 15 years
- **Coverage**: Domain + wildcard (*.domain.com)

### Nginx Configuration
- **Ports**: 80 (redirect to HTTPS), 443 (SSL)
- **SSL Protocols**: TLSv1.2, TLSv1.3
- **Security Headers**: HSTS, X-Frame-Options, etc.

## Monitoring

- Load balancer status: Cloudflare Dashboard > Traffic > Load Balancing
- SSL certificate status: Cloudflare Dashboard > SSL/TLS > Origin Server
- Health check logs: Available in Cloudflare Analytics

## Troubleshooting

1. **Certificate Issues**: Check ./ssl/origin.crt was created after `pulumi up`
2. **Health Check Failures**: Ensure /health endpoint returns 200 OK
3. **Connection Issues**: Verify firewall allows Cloudflare IPs
4. **DNS Issues**: Ensure DNS is proxied through Cloudflare (orange cloud)

## Security Best Practices

1. Always use Full (Strict) SSL mode in Cloudflare
2. Restrict VM access to Cloudflare IPs only
3. Keep Origin CA private key secure (./ssl/origin.key)
4. Monitor for SSL certificate expiration (though 15 years is quite long)
5. Enable Cloudflare Web Application Firewall (WAF) rules

## Costs

- Cloudflare Free Plan: Basic SSL included
- Load Balancing: $5/month for 2 origins, 500K DNS queries
- Additional origins: $5/month each
- Additional queries: $0.50 per 500K

## Support

For issues:
1. Check Pulumi logs: `pulumi logs`
2. Verify Cloudflare API permissions
3. Check Cloudflare Dashboard for errors
4. Review Nginx logs: `docker logs nginx-ssl-proxy`