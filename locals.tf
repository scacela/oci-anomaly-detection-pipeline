locals {
region_key = lower(data.oci_identity_regions.available_regions.regions.0.key)

new_compartment_id = module.iam.iam_compartment_id

iam_dynamic_group_matching_rule_ods = var.ods_is_deployed ? ["datasciencemodeldeployment.compartment.id='${local.new_compartment_id}', datasciencejobrun.compartment.id='${local.new_compartment_id}', datasciencenotebooksession.compartment.id='${local.new_compartment_id}'"] : null
iam_policy_statements_ods = var.ods_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage data-science-family in compartment id ${local.new_compartment_id}",
  "Allow dynamic-group ${var.iam_dynamic_group_name} to manage object-family in compartment id ${local.new_compartment_id}",
  "Allow dynamic-group ${var.iam_dynamic_group_name} to use virtual-network-family in compartment id ${local.new_compartment_id}",
  "Allow service datascience to use virtual-network-family in compartment id ${local.new_compartment_id}"] : null
iam_policy_statements_ads = var.ads_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage ai-service-anomaly-detection-family in compartment id ${local.new_compartment_id}"] : null

iam_policy_statements = flatten([local.iam_policy_statements_ods, local.iam_policy_statements_ads])
iam_dynamic_group_matching_rule = "Any {${flatten([local.iam_dynamic_group_matching_rule_ods])[0]}}"
}