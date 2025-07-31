import * as pulumi from "@pulumi/pulumi"
import * as fs from "fs"

// This function saves the Origin certificate to a file
export function saveCertificate(certificate: pulumi.Output<string>) {
    certificate.apply(cert => {
        if (cert) {
            fs.writeFileSync("./ssl/origin.crt", cert)
            console.log("Origin certificate saved to ./ssl/origin.crt")
        }
    })
}