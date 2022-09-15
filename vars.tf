# AUTH
variable "tenancy_ocid" { default = "" }
variable "user_ocid" { default = "" }
variable "fingerprint" { default = "" }
variable "private_key_path" { default = "" }
variable "region" { default = "" }

# iam
variable "parent_compartment_id" { default = "" }
variable "iam_compartment_name" { default = "AD_workshop" }
variable "iam_compartment_description" { default = "Compartment for Anomaly Detection workshop" }
variable "iam_compartment_enable_delete" { default = true }
variable "iam_policy_is_deployed" { default = true }
variable "iam_policy_name" { default = "AD_policy" }
variable "iam_policy_description" { default = "Policy for Anomaly Detection workshop" }
variable "iam_dynamic_group_name" { default = "AD_dynamic_group" }
variable "iam_dynamic_group_description" { default = "Dynamic Group for Anomaly Detection workshop" }

# ads
variable "ads_is_deployed" { default = true }
variable "ads_project_description" { default = "Project container for Anomaly Detection models" }
variable "ads_project_display_name" { default = "AD_model_project" }

# object_storage
variable "object_storage_is_deployed" { default = true }
variable "object_storage_bucket_name" { default = "AD_bucket" }
variable "object_storage_bucket_access_type" { default = "NoPublicAccess" }
variable "object_storage_bucket_storage_tier" { default = "Standard" }
variable "object_storage_bucket_versioning" { default = "Disabled" }

# ods
variable "ods_is_deployed" { default = true }
variable "ods_project_display_name" { default = "AD_data_science_project" }
variable "ods_notebook_session_display_name" { default = "AD_data_science_notebook_session" }
variable "ods_notebook_session_shape" { default = "VM.Standard.E3.Flex" }
variable "ods_notebook_session_ocpu" { default = 2 }
variable "ods_notebook_session_memory_in_gb" { default = 32 }
variable "ods_notebook_session_block_storage_size_in_gbs" { default = 50 }

# oke
variable "oke_is_deployed" { default = true }
variable "oke_is_kubernetes_dashboard_enabled" { default = true }
variable "oke_is_tiller_enabled" { default = true }
variable "oke_pods_cidr" { default = "10.244.0.0/16" }
variable "oke_services_cidr" { default = "10.96.0.0/16" }
variable "oke_cluster_name" { default = "AD_oke_cluster" }
variable "oke_node_pool_name" { default = "AD_oke_node_pool" }
variable "oke_kubernetes_version" { default = "v1.24.1" }
variable "oke_oracle_linux_os_version" { default = "7.9" }
variable "oke_node_pool_size" { default = 2 }
variable "oke_node_shape" { default = "VM.Standard.E3.Flex" }
variable "oke_node_ocpu" { default = 1 }
variable "oke_node_memory_in_gb" { default = 16 }
variable "oke_initial_node_labels_key" { default = "AD_oke_node_key" }
variable "oke_initial_node_labels_value" { default = "AD_oke_node_value" }
variable "oke_subnet_cidr" { default = "10.0.20.0/24" }
variable "oke_subnet_display_name" { default = "AD_oke_subnet" }
variable "oke_subnet_dns_label" { default = "okesub" }
variable "oke_rt_display_name" { default = "AD_oke_route_table" }
variable "oke_sl_display_name" { default = "AD_oke_security_list" }

# streaming
variable "streaming_is_deployed" { default = true }
variable "stream_pool_name" { default = "AD_stream_pool" }
variable "stream_name" { default = "AD_stream" }
variable "stream_partitions" { default = 1 }
variable "stream_retention_in_hours" { default = 168 }

# vcn
variable "vcn_is_deployed" { default = true }
variable "vcn_cidrs" {
  type = list(string)
  default = ["10.0.0.0/16"]
}
variable "vcn_display_name" { default = "AD_vcn" }
variable "vcn_dns_label" { default = "ad-vcn" }
variable "ng_display_name" { default = "AD_nat_gateway" }
variable "sg_display_name" { default = "AD_service_gateway" }