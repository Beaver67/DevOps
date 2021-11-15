# # ===============================================================================
# # Windows VM
# resource "azurerm_resource_group" "example" {
#   name     = "example-resources"
#   location = "eastus"
# }

# # Seems like only resources should be in here and we should be able to have all
# # of the resources here 
# # https://github.com/MiteshSharma/TerraformModules/blob/master/resources.tf

# # We might be able to use this as-is where we use a module to separate out the code
# # and STILL use the community/public azure resource
# # This way, our code is separated and we take advantage of public modules

# # TEST THIS at root and then as 


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
