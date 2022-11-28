variable "prefix" {
  default = "cguru"
}

variable "name" {
  default = "azure"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "West US"
}

variable "username" {
  type    = string
  default = "sysadmin"
}

variable "public_key" {
  type    = string
  default = "sysadmin.pub"
}

# Destination address prefix to be applied to all predefined rules
# Example ["10.0.3.0/32","10.0.3.128/32"]
variable "source_address_prefixes" {
  type    = list(string)
  default = ["*"]
}

# Variable Tags
variable "tags" {
  description = "The tags to associate with your network security group."
  type        = map(string)
  default = {
    environment = "development"
    cloud       = "azure"
    owner       = "devops"
    description = "Azure terraform lab"
  }
}