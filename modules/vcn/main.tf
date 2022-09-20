resource "oci_core_vcn" "vcn" {
  cidr_blocks     = var.vcn_cidrs
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}
resource "oci_core_internet_gateway" "ig" {
    #Required
    compartment_id = var.compartment_id
    vcn_id = oci_core_vcn.vcn.id
    display_name = var.ig_display_name
}
# Create NAT gateway to allow one way outbound internet traffic
resource "oci_core_nat_gateway" "ng" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = var.ng_display_name
}
# Create Service gateway to allow database server access to object storage object_storage_bucket for backups
resource "oci_core_service_gateway" "sg" {
  compartment_id = var.compartment_id
  services {
    service_id = var.service_id
  }
  display_name   = var.sg_display_name
  vcn_id         = oci_core_vcn.vcn.id
}