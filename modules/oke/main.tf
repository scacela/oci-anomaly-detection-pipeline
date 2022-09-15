resource "oci_containerengine_cluster" "oke_cluster" {
    # Required
    compartment_id = var.compartment_id
    kubernetes_version = var.oke_kubernetes_version
    name = var.oke_cluster_name
    vcn_id = var.vcn_id

    # Optional
    options {
        add_ons {
            is_kubernetes_dashboard_enabled = var.oke_is_kubernetes_dashboard_enabled
            is_tiller_enabled = var.oke_is_tiller_enabled
        }
        kubernetes_network_config {
            pods_cidr = var.oke_pods_cidr
            services_cidr = var.oke_services_cidr
        }
    }  
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
    # Required
    cluster_id = oci_containerengine_cluster.oke_cluster.id
    compartment_id = var.compartment_id
    kubernetes_version = var.oke_kubernetes_version
    name = var.oke_node_pool_name
    node_shape = var.oke_node_shape

    node_config_details {
        dynamic placement_configs {
          for_each = toset(var.availability_domain_names)
          content {
            availability_domain = placement_configs.key
            subnet_id = oci_core_subnet.oke_subnet.id
          }
        }
      size = var.oke_node_pool_size
       node_pool_pod_network_option_details {
        cni_type = "FLANNEL_OVERLAY" # other option: "OCI_VCN_IP_NATIVE"
       }
    }

    node_source_details {
         image_id = var.oke_image_id
         source_type = "image"
    }
 
    # Optional
    initial_node_labels {
        key = var.oke_initial_node_labels_key
        value = var.oke_initial_node_labels_value
    }
    dynamic node_shape_config {
        for_each = var.oke_node_shape == "VM.Standard.E3.Flex" || var.oke_node_shape == "VM.Standard.E4.Flex" ? [1] : []
        content {
        memory_in_gbs = var.oke_node_memory_in_gb
        ocpus = var.oke_node_ocpu
        }
    }
}

resource "oci_core_subnet" "oke_subnet" {
  cidr_block        = var.oke_subnet_cidr
  display_name      = var.oke_subnet_display_name
  compartment_id    = var.compartment_id
  vcn_id            = var.vcn_id
  dhcp_options_id   = var.vcn_default_dhcp_options_id
  route_table_id    = oci_core_route_table.oke_rt.id
  security_list_ids = [oci_core_security_list.oke_sl.id]
  prohibit_public_ip_on_vnic = true
  dns_label         = var.oke_subnet_dns_label
}

resource "oci_core_route_table" "oke_rt" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.oke_rt_display_name
  
  route_rules {
    destination       = var.service_cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.sg_id
  }
  route_rules {
      network_entity_id = var.ng_id
      destination       = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "oke_sl" {
  compartment_id = var.compartment_id
  display_name   = var.oke_sl_display_name
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = "ALL"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "ALL"
    source   = "0.0.0.0/0"
  }
}