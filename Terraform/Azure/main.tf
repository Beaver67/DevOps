# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

# NOTE - look at importing modules and how to do that properly
# We also use community modules, so we need to be able to separate out the code by
# having a module call a module maybe?

provider "azurerm" {
  features {}
}


module "dbModule" {
  source = "./modules/azure_db"

  sql_username        = var.sql_username
  sql_password        = var.sql_password
  resource_group_name = var.resource_group_name
  region_name         = var.region_name
  db_name             = var.db_name
  default_tags        = var.default_tags
  # env_name            = local.env_name


}
# # ===============================================================================
# # SQL Server DB
# module "sql-database" {
#   source              = "Azure/database/azurerm"
#   resource_group_name = var.resource_group_name
#   location            = var.region_name
#   db_name             = "beaver-base"
#   sql_admin_username  = var.sql_username
#   sql_password        = var.sql_password

#   tags = {
#     environment = "Terraform Getting Started"
#     costcenter  = "Beaver Cost Center"
#   }

# }

# # ===============================================================================
# # Windows VM
# resource "azurerm_resource_group" "example" {
#   name     = "example-resources"
#   location = "eastus"
# }

# module "windowsservers" {
#   source              = "Azure/compute/azurerm"
#   resource_group_name = azurerm_resource_group.example.name
#   is_windows_image    = true
#   vm_hostname         = "beaver-vm" // line can be removed if only one VM module per resource group
#   admin_username      = var.bvm_username
#   admin_password      = var.bvm_password
#   vm_os_simple        = "WindowsServer"
#   public_ip_dns       = ["beavervmips"] // change to a unique name per datacenter region
#   vnet_subnet_id      = module.network.vnet_subnets[0]
#   vm_size             = "Standard_D2as_v4"


#   depends_on = [azurerm_resource_group.example]
# }

# module "network" {
#   source              = "Azure/network/azurerm"
#   resource_group_name = azurerm_resource_group.example.name
#   subnet_prefixes     = ["10.0.1.0/24"]
#   subnet_names        = ["subnet1"]

#   depends_on = [azurerm_resource_group.example]
# }

# output "windows_vm_public_name" {
#   value = module.windowsservers.public_ip_dns_name
# }



