## inputs
locals {
	project_id		= var.project
        region                  = var.region
        zone                    = var.zone
        network                 = var.vpn_cloud_network
	vpn_name		= var.vpn_name
}

## outputs
output "project_id" {
        value           = local.project_id
}
output "region" {
        value           = local.region
}
output "zone" {
        value           = local.zone
}
output "network_id" {
        value           = local.network
}
