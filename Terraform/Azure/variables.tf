##################################################################################
# Setup
##################################################################################
variable "resource_group_name" {}

variable "region_name" {
  default = "eastus"
}

variable "default_tags" {}

##################################################################################
# Database
##################################################################################

# # Variable values come from terraform.tfvars (Must match the name exactly)
variable "sql_username" {
  type = string
}
variable "sql_password" {}

variable "db_name" {
  default = "beaverdb"
}
##################################################################################
# VMs
##################################################################################


# variable "bvm_username" {}
# variable "bvm_password" {}

# variable "aws_access_key" {}
# variable "aws_secret_key" {}
# variable "private_key_path" {}
# variable "key_name" {}
# variable "region" {
#   default = "us-east-1"
# }
# variable "network_address_space" {
#   type = map(string)
# }
# variable "instance_size" {
#   type = map(string)
# }
# variable "subnet_count" {
#   type = map(number)
# }
# variable "instance_count" {
#   type = map(number)
# }

# variable "billing_code_tag" {}
# variable "bucket_name_prefix" {}

# variable "dns_zone_name" {}
# variable "dns_resource_group" {}

##################################################################################
# LOCALS
##################################################################################

# locals {

#   env_name = lower(terraform.workspace)

#   #   # common_tags = {
#   #   #   BillingCode = var.billing_code_tag
#   #   #   Environment = local.env_name
#   #   # }

#   #   #   s3_bucket_name = "${var.bucket_name_prefix}-${local.env_name}-${random_integer.rand.result}"

# }
