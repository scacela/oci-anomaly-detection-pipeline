output "iam_compartment_id" {
  value = module.iam.iam_compartment_id
}
output "iam_policy_id" {
  value = var.iam_policy_is_deployed ? module.iam.iam_policy_id : null
}
output "iam_dynamic_group_id" {
  value = var.iam_policy_is_deployed ? module.iam.iam_dynamic_group_id : null
}
output "ads_project_id" {
  value = var.object_storage_is_deployed ? module.ads[0].ads_project_id : null
}
output "object_storage_bucket_id" {
  value = var.object_storage_is_deployed ? module.object_storage[0].object_storage_bucket_id : null
}
output "ods_notebook_session_id" {
  value = var.ods_is_deployed ? module.ods[0].ods_notebook_session_id : null
}
output "oke_cluster_id" {
  value = var.oke_is_deployed ? module.oke[0].oke_cluster_id : null
}
output "oke_node_pool_id" {
  value = var.oke_is_deployed ? module.oke[0].oke_node_pool_id : null
}
output "oke_subnet_cluster_id" {
  value = var.oke_is_deployed ? module.oke[0].oke_subnet_cluster_id : null
}
output "oke_subnet_lb_id" {
  value = var.oke_is_deployed ? module.oke[0].oke_subnet_lb_id : null
}
output "oke_subnet_worker_id" {
  value = var.oke_is_deployed ? module.oke[0].oke_subnet_worker_id : null
}
output "ons_topic_id" {
  value = var.ons_is_deployed ? module.ons[0].ons_topic_id : null
}
output "ons_subscription_id" {
  value = var.ons_is_deployed ? module.ons[0].ons_subscription_id : null
}
output "stream_pool_id" {
  value = var.streaming_is_deployed ? module.streaming[0].stream_pool_id : null
}
output "stream_id" {
  value = var.streaming_is_deployed ? module.streaming[0].stream_id : null
}
output "vcn_id" {
  value = var.vcn_is_deployed ? module.vcn[0].vcn_id : null
}