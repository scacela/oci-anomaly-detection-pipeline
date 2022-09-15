output "oke_cluster_id" {
  value = oci_containerengine_cluster.oke_cluster.id
}
output "oke_node_pool_id" {
  value = oci_containerengine_node_pool.oke_node_pool.id
}
output "oke_subnet_id" {
  value = oci_core_subnet.oke_subnet.id
}