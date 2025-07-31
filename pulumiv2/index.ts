import * as pulumi from "@pulumi/pulumi"
import * as docker from "@pulumi/docker"
import * as command from "@pulumi/command"
import * as cloudflare from "@pulumi/cloudflare"
import * as fs from "fs"
import { saveCertificate } from "./save-cert"

/**
 * This Pulumi program sets up a self-hosted development platform using Docker containers.
 * It includes Portainer for container management and can be extended with additional services.
 * Now includes Cloudflare SSL and Load Balancer configuration.
 */

// Configuration
const config = new pulumi.Config()
const cloudflareZoneId = config.require("cloudflareZoneId")
const domain = config.get("domain") || "patio.example.com"


const network = new docker.Network("dev-network", {
    name: "dev-platform-network",
})

const portainer = new docker.Container("portainer", {
    image: "portainer/portainer-ce:latest",
    name: "portainer",
    restart: "always",
    ports: [{
        internal: 9000,
        external: 9000,
    }],
    volumes: [{
        containerPath: "/var/run/docker.sock",
        hostPath: "/var/run/docker.sock",
    }, {
        containerPath: "/data",
        hostPath: "portainer_data",
    }],
    networksAdvanced: [{
        name: network.name,
    }],
})

const getLocalIp = new command.local.Command("get-local-ip", {
    create: "hostname -I | awk '{print $1}'"  // Most reliable on Linux/Mac
})

export const localIpAddress = getLocalIp.stdout

// Export the Portainer URL
export const portainerUrl = pulumi.interpolate`http://${localIpAddress}:${portainer.ports[0].external}`

// Cloudflare SSL Configuration
// Read the CSR file
const csrContent = fs.readFileSync("./ssl/origin.csr", "utf8")

// Create Cloudflare Origin CA Certificate
const originCert = new cloudflare.OriginCaCertificate("origin-cert", {
    csr: csrContent,
    hostnames: [domain, `*.${domain}`],
    requestType: "origin-rsa",
    requestedValidity: 5475, // 15 years
})

// Create Load Balancer Monitor for health checks
const lbMonitor = new cloudflare.LoadBalancerMonitor("health-monitor", {
    accountId: config.require("cloudflareAccountId"),
    type: "https",
    description: "HTTPS health check for dev platform",
    method: "GET",
    path: "/health",
    interval: 60,
    timeout: 5,
    retries: 2,
    expectedCodes: "200",
    allowInsecure: true,
})

// Create Load Balancer Pool
const lbPool = new cloudflare.LoadBalancerPool("main-pool", {
    accountId: config.require("cloudflareAccountId"),
    name: "dev-platform-pool",
    origins: [{
        name: "primary-vm",
        address: "192.3.231.145",
        enabled: true,
        weight: 1,
    }],
    minimumOrigins: 1,
    monitor: lbMonitor.id,
    description: "Main pool for dev platform",
    notificationEmail: config.get("notificationEmail"),
})

// Create Load Balancer
const loadBalancer = new cloudflare.LoadBalancer("main-lb", {
    zoneId: cloudflareZoneId,
    name: domain,
    fallbackPool: lbPool.id,
    defaultPools: [lbPool.id],
    description: "Load balancer for dev platform",
    proxied: true,
    sessionAffinity: "cookie",
    sessionAffinityTtl: 1800,
})

// Create Nginx container for SSL termination
const nginx = new docker.Container("nginx", {
    image: "nginx:alpine",
    name: "nginx-ssl-proxy",
    restart: "always",
    ports: [{
        internal: 443,
        external: 443,
    }, {
        internal: 80,
        external: 80,
    }],
    volumes: [{
        containerPath: "/etc/nginx/ssl",
        hostPath: pulumi.interpolate`${process.cwd()}/ssl`,
    }, {
        containerPath: "/etc/nginx/conf.d",
        hostPath: pulumi.interpolate`${process.cwd()}/nginx-conf`,
    }],
    networksAdvanced: [{
        name: network.name,
    }],
    dependsOn: [portainer],
})

// Save the certificate to file for Nginx to use
saveCertificate(originCert.certificate)

// Export SSL certificate info
export const originCertificate = originCert.certificate
export const certificateExpiresOn = originCert.expiresOn
export const loadBalancerHostname = loadBalancer.name


