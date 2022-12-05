# terraform-azure
## **vm-linux-simple**

This structure creates an Azure simple Linux CentOS VM with Terraform and HCL.

Notes:

1. It is possible configure the resource_group_name by using variable (`variables.tf`) or putting it interactively using `var` parameter as following:

    ```sh
    terraform destroy -var "resource_group_name=my_resourcegroup_id"
    ```
2. Put you local restricted public IP or wild `["*"]` to set `Inbound` *source_address_prefixes* security rule in `variables.tf`.
