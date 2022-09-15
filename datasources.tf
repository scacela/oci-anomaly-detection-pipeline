data "oci_core_services" "services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

data "oci_identity_regions" "available_regions" {
  filter {
    name = "name"
    values = [var.region]
    regex = false
  }
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.parent_compartment_id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.parent_compartment_id
}

data "oci_core_images" "compute_images" {
    compartment_id = var.parent_compartment_id
    operating_system = "Oracle Linux"
    operating_system_version = var.oke_oracle_linux_os_version
    shape = var.oke_node_shape
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}