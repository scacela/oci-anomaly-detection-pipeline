locals {
  iam_policy_statements_ods = var.ods_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage data-science-family in compartment id ${oci_identity_compartment.compartment.id}",
    "Allow dynamic-group ${var.iam_dynamic_group_name} to manage object-family in compartment id ${oci_identity_compartment.compartment.id}",
    "Allow dynamic-group ${var.iam_dynamic_group_name} to use virtual-network-family in compartment id ${oci_identity_compartment.compartment.id}",
    "Allow service datascience to use virtual-network-family in compartment id ${oci_identity_compartment.compartment.id}"] : []
  iam_policy_statements_ads = var.ads_is_deployed ? ["Allow dynamic-group ${var.iam_dynamic_group_name} to manage ai-service-anomaly-detection-family in compartment id ${oci_identity_compartment.compartment.id}"] : []
  iam_policy_statements = flatten([local.iam_policy_statements_ods, local.iam_policy_statements_ads])
  
  iam_dynamic_group_matching_rule_ods = var.ods_is_deployed ? ["datasciencemodeldeployment.compartment.id='${oci_identity_compartment.compartment.id}', datasciencejobrun.compartment.id='${oci_identity_compartment.compartment.id}', datasciencenotebooksession.compartment.id='${oci_identity_compartment.compartment.id}'"] : []
  iam_dynamic_group_matching_rule_is_deployed = var.ods_is_deployed ? true : false # add conditions using logical OR as additional modules require Dynamic Group membership,
  iam_dynamic_group_matching_rule = local.iam_dynamic_group_matching_rule_is_deployed ? "Any {${flatten([local.iam_dynamic_group_matching_rule_ods])[0]}}" : null
}