variable "project" {}
variable "region" {}
variable "zone" {}
variable "vpn_cloud_network" {
	default	= "default"
}
variable "vpn_cloud_project" {
	default	= null
}
variable "vpn_peer_address" {}
variable "vpn_name" {}
variable "bgp_cloud_address" {}
variable "bgp_cloud_asn" {}
variable "bgp_peer_address" {}
variable "bgp_peer_asn" {}
variable "shared_secret" {}
