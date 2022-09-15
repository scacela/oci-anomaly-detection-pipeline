module "iam" {
  source = "./modules/iam"
  # configuration
  parent_compartment_id = var.parent_compartment_id
  iam_compartment_description = var.iam_compartment_description
  iam_compartment_name = var.iam_compartment_name
  iam_compartment_enable_delete = var.iam_compartment_enable_delete
  tenancy_ocid = var.tenancy_ocid
  iam_policy_is_deployed = var.iam_policy_is_deployed
  iam_policy_statements = local.iam_policy_statements
  iam_dynamic_group_matching_rule = local.iam_dynamic_group_matching_rule
  iam_policy_name = var.iam_policy_name
  iam_policy_description = var.iam_policy_description
  iam_dynamic_group_name = var.iam_dynamic_group_name
  iam_dynamic_group_description = var.iam_dynamic_group_description
}

module "ads" {
  count = var.ads_is_deployed ? 1 : 0
  source = "./modules/ads"
  # configuration
  compartment_id = local.new_compartment_id
  ads_project_description = var.ads_project_description
  ads_project_display_name = var.ads_project_display_name
}

module "object_storage" {
  count = var.object_storage_is_deployed ? 1 : 0
  source = "./modules/object_storage"
  # configuration
  object_storage_bucket_name = var.object_storage_bucket_name
  object_storage_bucket_access_type = var.object_storage_bucket_access_type
  object_storage_bucket_storage_tier = var.object_storage_bucket_storage_tier
  object_storage_bucket_versioning = var.object_storage_bucket_versioning
  compartment_id = local.new_compartment_id
}

module "ods" {
  depends_on = [module.vcn]
  count = var.vcn_is_deployed && var.ods_is_deployed ? 1 : 0
  source = "./modules/ods"
  # configuration
  ods_project_display_name = var.ods_project_display_name
  ods_notebook_session_display_name = var.ods_notebook_session_display_name
  ods_notebook_session_shape = var.ods_notebook_session_shape
  ods_notebook_session_ocpu = var.ods_notebook_session_ocpu
  ods_notebook_session_memory_in_gb = var.ods_notebook_session_memory_in_gb
  ods_notebook_session_block_storage_size_in_gbs = var.ods_notebook_session_block_storage_size_in_gbs
  compartment_id = local.new_compartment_id
}

module "oke" {
  depends_on = [module.vcn]
  count = var.vcn_is_deployed && var.oke_is_deployed ? 1 : 0
  source = "./modules/oke"
  # configuration
  oke_subnet_cidr = var.oke_subnet_cidr
  oke_subnet_display_name = var.oke_subnet_display_name
  oke_subnet_dns_label = var.oke_subnet_dns_label
  oke_rt_display_name = var.oke_rt_display_name
  oke_sl_display_name = var.oke_sl_display_name
  oke_is_kubernetes_dashboard_enabled = var.oke_is_kubernetes_dashboard_enabled
  oke_is_tiller_enabled = var.oke_is_tiller_enabled
  oke_pods_cidr = var.oke_pods_cidr
  oke_services_cidr = var.oke_services_cidr
  oke_cluster_name = var.oke_cluster_name
  oke_node_pool_name = var.oke_node_pool_name
  compartment_id = local.new_compartment_id
  oke_kubernetes_version = var.oke_kubernetes_version
  oke_image_id = data.oci_core_images.compute_images.images[0].id # first element for latest image
  availability_domain_names = [ for i in data.oci_identity_availability_domains.ads.availability_domains : i.name ]
  oke_node_pool_size = var.oke_node_pool_size
  oke_node_shape = var.oke_node_shape
  oke_initial_node_labels_key = var.oke_initial_node_labels_key
  oke_initial_node_labels_value = var.oke_initial_node_labels_value
  oke_node_ocpu = var.oke_node_ocpu
  oke_node_memory_in_gb = var.oke_node_memory_in_gb
  
  vcn_id = module.vcn[0].vcn_id
  vcn_default_dhcp_options_id = module.vcn[0].vcn_default_dhcp_options_id
  service_cidr_block = data.oci_core_services.services.services.0.cidr_block
  ng_id = module.vcn[0].ng_id
  sg_id = module.vcn[0].sg_id
}

module "streaming" {
  count = var.streaming_is_deployed ? 1 : 0
  source = "./modules/streaming"
  # configuration
  stream_name = var.stream_name
  stream_partitions = var.stream_partitions
  stream_retention_in_hours = var.stream_retention_in_hours
  stream_pool_name = var.stream_pool_name
  compartment_id = local.new_compartment_id
}

module "vcn" {
  count = var.vcn_is_deployed ? 1 : 0
  source = "./modules/vcn"
  # configuration
  vcn_display_name = var.vcn_display_name
  vcn_dns_label = var.vcn_dns_label
  ng_display_name = var.ng_display_name
  service_id = data.oci_core_services.services.services.0.id
  sg_display_name = var.sg_display_name
  vcn_cidrs = var.vcn_cidrs
  compartment_id = local.new_compartment_id
}