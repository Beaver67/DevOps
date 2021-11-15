locals {
  env_name = terraform.workspace
}

# SQL Server DB
module "sql-database" {
  source              = "Azure/database/azurerm"
  resource_group_name = "${var.resource_group_name}-${local.env_name}"
  location            = var.region_name
  db_name             = "${var.db_name}-${local.env_name}"
  sql_admin_username  = var.sql_username
  sql_password        = var.sql_password

  tags = var.default_tags

}
