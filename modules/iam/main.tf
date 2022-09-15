resource "oci_identity_compartment" "compartment" {
    #Required
    compartment_id = var.parent_compartment_id
    description = var.iam_compartment_description
    name = var.iam_compartment_name
    enable_delete = var.iam_compartment_enable_delete
}

resource "oci_identity_policy" "policy" {
  count = var.iam_policy_is_deployed ? 1 : 0
  #Required
  compartment_id = var.tenancy_ocid
  description = var.iam_policy_description
  name = var.iam_policy_name
  statements = var.iam_policy_statements
}

resource "oci_identity_dynamic_group" "dynamic_group" {
    count = var.iam_policy_is_deployed ? 1 : 0
    #Required
    compartment_id = var.tenancy_ocid
    description = var.iam_dynamic_group_description
    matching_rule = var.iam_dynamic_group_matching_rule
    name = var.iam_dynamic_group_name
}