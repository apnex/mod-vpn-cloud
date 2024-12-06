## routed-vpn variables
locals {
	vpn_peer_address	= var.vpn_peer_address
	vpn_cloud_project	= coalesce(var.vpn_cloud_project, local.project_id)
	vpn_cloud_network	= var.vpn_cloud_network
	vpn_cloud_router_name	= "cr-vpn-${local.vpn_name}"
	bgp_cloud_address	= var.bgp_cloud_address
	bgp_cloud_asn		= var.bgp_cloud_asn
	bgp_peer_address	= var.bgp_peer_address
	bgp_peer_asn		= var.bgp_peer_asn
	shared_secret		= var.shared_secret
}

## vpn router
resource "google_compute_router" "router" {
	project                 = local.vpn_cloud_project
	region                  = local.region
	name                    = local.vpn_cloud_router_name
	network			= try(
		local.vpn_cloud_network
	)
	bgp {
		asn                     = local.bgp_cloud_asn
		advertise_mode          = "CUSTOM"
		advertised_groups       = ["ALL_SUBNETS"]
        }
}

## configure cloud VPN in GCP
module "vpn_ha" {
	source				= "terraform-google-modules/vpn/google//modules/vpn_ha"
	version				= "~> 4.0"
	project_id			= local.vpn_cloud_project
	region				= local.region
	network				= "https://www.googleapis.com/compute/v1/projects/${local.project_id}/global/networks/${local.vpn_cloud_network}"
	name				= "vpn-${local.vpn_name}-to-onprem"
	create_vpn_gateway		= true
	router_name			= google_compute_router.router.name
	router_asn			= local.bgp_cloud_asn

	peer_external_gateway = {
		name            = "vpngw-${local.vpn_name}"
		redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
                interfaces = [
                        {
                                id		= 0
                                ip_address	= local.vpn_peer_address
                        }
                ]
        }

        tunnels = {
                remote-0 = {
                        bgp_peer = {
                                address = local.bgp_peer_address
                                asn     = local.bgp_peer_asn
                        }
                        bgp_session_name                = "bgp-${local.vpn_name}-to-onprem"
                        bgp_session_range               = "${local.bgp_cloud_address}/30"
                        ike_version                     = 2
                        peer_external_gateway_interface = 0
                        vpn_gateway_interface           = 0
                        shared_secret                   = local.shared_secret
                }
        }
	depends_on = [
		google_compute_router.router
	]
}

### outputs
output "vpn_cloud_project" {
	value	= local.vpn_cloud_project
}
output "vpn_cloud_network" {
	value	= local.vpn_cloud_network
}
output "vpn_name" {
	value	= local.vpn_name
}
output "gateway_name" {
	value	= module.vpn_ha.name
}
output "vpn_gateway_address" {
	value	= module.vpn_ha.gateway[0].vpn_interfaces[0].ip_address	
}
output "vpn_peer_address" {
	value	= module.vpn_ha.external_gateway.interface[0].ip_address
}
output "router_name" {
	value	= google_compute_router.router.name
}
output "router_bgp_asn" {
	value	= google_compute_router.router.bgp[0].asn
}
