import * as pulumi from "@pulumi/pulumi"
import * as docker from "@pulumi/docker"
import * as command from "@pulumi/command"

/**
 * This Pulumi program sets up a self-hosted development platform using Docker containers.
 * It includes Portainer for container management and can be extended with additional services.
 */


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


