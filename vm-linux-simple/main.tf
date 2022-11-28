locals {
  environment = "lab"
  owner       = "alexmbarbosa"
}


data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.this.name #azurerm_resource_group.example.name
  location            = var.location
}

resource "azurerm_subnet" "this" {
  name                 = "${var.prefix}-network"
  resource_group_name  = data.azurerm_resource_group.this.name #azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs ----------------------------------------
resource "azurerm_public_ip" "this" {
  name                = "${var.prefix}-pip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Dynamic"
}
# Create public IPs ----------------------------------------

resource "azurerm_network_interface" "this" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id #azurerm_public_ip.my_terraform_public_ip.id
  }
  /* ip_configuration {
    name                          = "${var.prefix}-ipconfig"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  } */
}

# Create Network Security Group and rule ---------------------
resource "azurerm_network_security_group" "this" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.source_address_prefixes
    destination_address_prefix = "*"
  }
}
# Create Network Security Group and rule ---------------------

# Connect the security group to the network interface --------------------------
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}
# Connect the security group to the network interface --------------------------

resource "azurerm_ssh_public_key" "this" {
  name                = "${var.prefix}-${var.name}-key"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  public_key          = file("./files/${var.public_key}")
}

# Azure "Linux" Virtual Machine -------------------------------------------------
resource "azurerm_linux_virtual_machine" "this" {
  name                = "vm-${var.prefix}-${var.name}"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file("./files/${var.public_key}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  tags = merge(
    var.tags,
    {
      environment = local.environment
      owner       = local.owner
    },
  )
}