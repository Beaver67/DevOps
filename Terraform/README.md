# Terraform Notes

This readme highlights some common notes and features of Terraform that are used frequently.

Terraform is used to provision resources in the cloud (VMs, DBs, Networks etc) through code (Infrastructure as Code). This allows for more consistent and maintainable infrastructure.

Currently, only Azure products have been deployed using Terraform.

TODO: Setup files in GCP and AWS

TODO: Look at best way to organize/deploy resource groups in Azure


## Common Commands

| Command         | Usage           |
| ------------- |:-------------|
| terraform init     | Initializes the configuration file|
| terraform fmt     | Formats the configuration file     |
| terraform validate     | Validates the configuration file     |
| terraform plan -out <myplanname.tfplan> | Creates the plan for what will be doing and (optionally) ports the output to a file     |
| terraform apply <myplanname.tfplan> | Applies all of the items in the config file to the destination platform     |
| terraform destroy | Destroys all of the resources in the configuration file     |

## Workspaces

Use Terraform workspaces to separate out the dev/test/prod

NOTE: env variable files (./dev/dev.tfvars, ./test/test.tfvars, ./prod/prod.tfvars) must be used.

Any variables not listed in the env variable files will have the values invoked with the variable file from the root.

 **Be careful to match environments**

| Command         | Usage           |
| ------------- |:-------------|
| terraform workspaces new <workspace_name>     | Creates a new workspace|
| terraform workspaces show      | Shows the current workspace    |
| terraform workspaces list      | List the workspaces (*current)    |
| terraform workspaces select <workspace_name>      | Selects a workspace   |
| terraform plan <-out ./env/dev.tfplan -var-file ./env/dev.tfvars> | Creates the plan for what will be doing and (optionally) ports the output to a file using the <workspace_name.tfvars file>    |
| terraform apply <./env/dev.tfplan> | Applies all of the items in the config file to the destination platform     |
| terraform destroy -var-file ./env/dev.tfvars| Destroys all of the resources in the configuration file (make sure to include the vars file)   |

## Local Module Flow

Example with Azure folder (note - dev/test/prod variable files are in a singular env folder)

    ├── main.tf                <- Main terraform file that calls other modules and resources
    ├── outputs.tf             <- Any outputs that are necessary at the project level
    ├── terraform.tfvars       <- Variables that need to be secret
    ├── variables.tf           <- Variable definitions (can include default values)
    ├── env
    │   └── dev.tfvars         <- Dev variables used in calling modules/resources
    │   └── Prod.tfvars        <- Prod variables used in calling modules/resources
    │   └── Test.tfvars        <- Test variables used in calling modules/resources
    ├── modules                  
    │   └── azure_db           <- Resource to be deployed         
    │   │   └── main.tf        <- file to define the resources 
    │   │   └── outputs.tf     <- defines any outputs that are necessary  
    │   │   └── variables.tf   <- defines variables used in the main.tf file  
    │   └── Any other resource <- Resource to be deployed         
    │   │   └── main.tf        <- file to define the resources 
    │   │   └── outputs.tf     <- defines any outputs that are necessary  
    │   │   └── variables.tf   <- defines variables used in the main.tf file  
    ├── prod 
    │   └── prod.tfvars        <- Prod variables used in calling modules/resources
    ├── test                
    │   └── test.tfvars        <- Test variables used in calling modules/resources

NOTE: the variable definitions MUST match between root and module

### Root of Azure:

variables.tf  - variable definitions that are used in main.tf

```python
variable "sql_username" {
  type = string
}
variable "sql_password" {}
```
terraform.tfvars - values for the variables described in variables.tf

```python
sql_username = "admin"
sql_password = "P@ssw0rd12345!"
```

main.tf - calls the module 

### modules/azure_db
variables.tf  - variable definitions that are used in main.tf (match the ones used in the root of Azure)

main.tf - Module setup - consume the variables that are defined

```javascript
sql_admin_username  = var.sql_username
sql_password        = var.sql_password
```


## Common modules

Use this to learn about how to structure your code for configuration of a lot of resources

https://learn.hashicorp.com/tutorials/terraform/module-create?in=terraform/modules

https://youtu.be/lwsuhO8tBvQ

Excellent way to lay out the code
https://github.com/scubaninja/Ch9Demo-Terraform-Modules


### Azure

https://registry.terraform.io/modules/Azure/compute/azurerm/latest?tab=inputs
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine
https://registry.terraform.io/modules/Azure/database/azurerm/latest
