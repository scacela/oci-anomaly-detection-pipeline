resource "oci_containerengine_cluster" "oke_cluster" {
    # Required
    compartment_id = var.compartment_id
    kubernetes_version = var.oke_kubernetes_version
    name = var.oke_cluster_name
    vcn_id = var.vcn_id

    endpoint_config {
      is_public_ip_enabled = true
      subnet_id = oci_core_subnet.oke_subnet_cluster.id
    }

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
        service_lb_subnet_ids = [oci_core_subnet.oke_subnet_lb.id]
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
            subnet_id = oci_core_subnet.oke_subnet_worker.id
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

# Subnet for Cluster

resource "oci_core_subnet" "oke_subnet_cluster" {
  cidr_block        = var.oke_subnet_cluster_cidr
  display_name      = var.oke_subnet_cluster_display_name
  compartment_id    = var.compartment_id
  vcn_id            = var.vcn_id
  dhcp_options_id   = var.vcn_default_dhcp_options_id
  route_table_id    = oci_core_route_table.oke_rt_cluster.id
  security_list_ids = [oci_core_security_list.oke_sl_cluster.id]
  prohibit_public_ip_on_vnic = false
  dns_label         = var.oke_subnet_cluster_dns_label
}

resource "oci_core_route_table" "oke_rt_cluster" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.oke_rt_cluster_display_name
  
  route_rules {
      network_entity_id = var.ig_id
      destination       = "0.0.0.0/0"
      description = "traffic to/from internet"
  }
}

resource "oci_core_security_list" "oke_sl_cluster" {
  compartment_id = var.compartment_id
  display_name   = var.oke_sl_cluster_display_name
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol = 6
    destination   = var.service_cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Allow Kubernetes Control Plane to communicate with OKE"
    stateless   = false
    tcp_options {
        # destination port range
        max = 443
        min = 443
    }
  }
  egress_security_rules {
    protocol = 6
    destination   = var.oke_subnet_worker_cidr
    description = "All traffic to worker nodes"
    stateless   = false
    tcp_options {
        # destination port range
        max = 443
        min = 443
    }
  }
  egress_security_rules {
    protocol    = 1
    destination = var.oke_subnet_worker_cidr
    description = "Path discovery"
    stateless   = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"
    description = "External access to Kubernetes API endpoint"
    stateless   = false
    tcp_options {
        # destination port range
        max = 6443
        min = 6443
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.oke_subnet_worker_cidr
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    stateless   = false
    tcp_options {
        # destination port range
        max = 6443
        min = 6443
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.oke_subnet_worker_cidr
    description = "Kubernetes worker to control plane communication"
    stateless   = false
    tcp_options {
        # destination port range
        max = 12250
        min = 12250
    }
  }
  ingress_security_rules {
    protocol    = 1
    source      = var.oke_subnet_worker_cidr
    description = "Path discovery"
    stateless   = false
    icmp_options {
      type = 3
      code = 4
    }
  }
}

# Subnet for Load Balancer

resource "oci_core_subnet" "oke_subnet_lb" {
  cidr_block        = var.oke_subnet_lb_cidr
  display_name      = var.oke_subnet_lb_display_name
  compartment_id    = var.compartment_id
  vcn_id            = var.vcn_id
  dhcp_options_id   = var.vcn_default_dhcp_options_id
  route_table_id    = oci_core_route_table.oke_rt_lb.id
  security_list_ids = [oci_core_security_list.oke_sl_lb.id]
  prohibit_public_ip_on_vnic = false
  dns_label         = var.oke_subnet_lb_dns_label
}

resource "oci_core_route_table" "oke_rt_lb" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.oke_rt_lb_display_name
  
  route_rules {
      network_entity_id = var.ig_id
      destination       = "0.0.0.0/0"
      description = "traffic to/from internet"
  }
}

resource "oci_core_security_list" "oke_sl_lb" {
  compartment_id = var.compartment_id
  display_name   = var.oke_sl_lb_display_name
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = 6
    destination = var.oke_subnet_worker_cidr
    stateless = false
    tcp_options {
        # destination port range
        max = 30000
        min = 32767
    }
  }
  egress_security_rules {
    protocol    = 6
    destination = var.oke_subnet_worker_cidr
    stateless = false
    tcp_options {
        # destination port range
        max = 10256
        min = 10256
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"
    stateless = false
    tcp_options {
        # destination port range
        max = 5000
        min = 5000
    }
  }
}

# Subnet for Worker

resource "oci_core_subnet" "oke_subnet_worker" {
  cidr_block        = var.oke_subnet_worker_cidr
  display_name      = var.oke_subnet_worker_display_name
  compartment_id    = var.compartment_id
  vcn_id            = var.vcn_id
  dhcp_options_id   = var.vcn_default_dhcp_options_id
  route_table_id    = oci_core_route_table.oke_rt_worker.id
  security_list_ids = [oci_core_security_list.oke_sl_worker.id]
  prohibit_public_ip_on_vnic = true
  dns_label         = var.oke_subnet_worker_dns_label
}

resource "oci_core_route_table" "oke_rt_worker" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.oke_rt_worker_display_name
  
  route_rules {
    destination       = var.service_cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = var.sg_id
    description = "traffic to the internet"
  }
  route_rules {
    network_entity_id = var.ng_id
    destination       = "0.0.0.0/0"
    description = "traffic to OCI services"
  }
}

resource "oci_core_security_list" "oke_sl_worker" {
  compartment_id = var.compartment_id
  display_name   = var.oke_sl_worker_display_name
  vcn_id         = var.vcn_id

  egress_security_rules {
    protocol    = "ALL"
    destination = var.oke_subnet_worker_cidr
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    stateless   = false
  }
  egress_security_rules {
    protocol = 6
    destination   = var.oke_subnet_cluster_cidr
    description = "Access to Kubernetes API Endpoint"
    stateless   = false
    tcp_options {
        # destination port range
        max = 6443
        min = 6443
    }
  }
  egress_security_rules {
    protocol = 6
    destination = var.oke_subnet_cluster_cidr
    description = "Kubernetes worker to control plane communication"
    stateless   = false
    tcp_options {
        # destination port range
        max = 12250
        min = 12250
    }
  }
  egress_security_rules {
    protocol    = 1
    destination = var.oke_subnet_cluster_cidr
    description = "Path discovery"
    stateless   = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  egress_security_rules {
    protocol = 6
    destination   = var.service_cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    description = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    stateless   = false
    tcp_options {
        # destination port range
        max = 443
        min = 443
    }
  }
  egress_security_rules {
    protocol    = 1
    destination = "0.0.0.0/0"
    description = "ICMP Access from Kubernetes Control Plane"
    stateless   = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  egress_security_rules {
    protocol    = "ALL"
    destination = "0.0.0.0/0"
    description = "Worker Nodes access to Internet"
    stateless   = false
  }

  ingress_security_rules {
    protocol = "ALL"
    source   = var.oke_subnet_worker_cidr
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    stateless   = false
  }
  ingress_security_rules {
    protocol    = 1
    source      = var.oke_subnet_cluster_cidr
    description = "Path discovery"
    stateless   = false
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol = 6
    source   = var.oke_subnet_cluster_cidr
    description = "TCP access from Kubernetes Control Plane"
    stateless   = false
  }
  ingress_security_rules {
    protocol = 6
    source   = "0.0.0.0/0"
    description = "Inbound SSH traffic to worker nodes"
    stateless   = false
    tcp_options {
        # destination port range
        max = 22
        min = 22
    }
  }
    ingress_security_rules {
    protocol = 6
    source   = var.oke_subnet_lb_cidr
    stateless   = false
    tcp_options {
        # destination port range
        max = 30000
        min = 32767
    }
  }
    ingress_security_rules {
    protocol = 6
    source   = var.oke_subnet_lb_cidr
    stateless   = false
    tcp_options {
        # destination port range
        max = 10256
        min = 10256
    }
  }
}