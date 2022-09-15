resource "oci_objectstorage_bucket" "object_storage_bucket" {
    #Required
    compartment_id = var.compartment_id
    name = var.object_storage_bucket_name
    namespace = data.oci_objectstorage_namespace.namespace.namespace

    #Optional
    access_type = var.object_storage_bucket_access_type
    storage_tier = var.object_storage_bucket_storage_tier
    versioning = var.object_storage_bucket_versioning
}