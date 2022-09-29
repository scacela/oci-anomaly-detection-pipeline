locals {
region_key = lower(data.oci_identity_regions.available_regions.regions.0.key)

new_compartment_id = module.iam.iam_compartment_id

# add petnames to resources that must be unique within the tenancy
iam_compartment_name = "${var.iam_compartment_name}_${random_pet.random_pet_name.id}"
iam_policy_name = "${var.iam_policy_name}_${random_pet.random_pet_name.id}"
iam_dynamic_group_name = "${var.iam_dynamic_group_name}_${random_pet.random_pet_name.id}"
ons_topic_name = "${var.ons_topic_name}_${random_pet.random_pet_name.id}"
object_storage_bucket_name = "${var.object_storage_bucket_name}_${random_pet.random_pet_name.id}"

iam_dynamic_group_matching_rule_ods = var.ods_is_deployed ? ["datasciencemodeldeployment.compartment.id='${local.new_compartment_id}', datasciencejobrun.compartment.id='${local.new_compartment_id}', datasciencenotebooksession.compartment.id='${local.new_compartment_id}'"] : []
iam_policy_statements_ods = var.ods_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage data-science-family in compartment id ${local.new_compartment_id}",
  "Allow dynamic-group ${var.iam_dynamic_group_name} to manage object-family in compartment id ${local.new_compartment_id}",
  "Allow dynamic-group ${var.iam_dynamic_group_name} to use virtual-network-family in compartment id ${local.new_compartment_id}",
  "Allow service datascience to use virtual-network-family in compartment id ${local.new_compartment_id}"] : []
iam_policy_statements_ads = var.ads_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage ai-service-anomaly-detection-family in compartment id ${local.new_compartment_id}"] : []

iam_policy_statements = flatten([local.iam_policy_statements_ods, local.iam_policy_statements_ads])
iam_dynamic_group_matching_rule = length(local.iam_dynamic_group_matching_rule_ods) > 0 ? "Any {${flatten([local.iam_dynamic_group_matching_rule_ods])[0]}}" : null
}

resource "random_pet" "random_pet_name" {
  length = 2
  separator = "_"
  prefix = var.name_for_resources
}