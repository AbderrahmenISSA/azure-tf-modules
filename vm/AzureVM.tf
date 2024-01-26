resource "azurerm_network_security_group" "nsg" {
    name                  = "${var.APP_NAME}-${var.ENV_PREFIX}-nsg"
    location              = var.RG_LOCATION
    resource_group_name   = var.RG_NAME
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.APP_NAME}-${var.ENV_PREFIX}-ip"
  resource_group_name = var.RG_NAME
  location            = var.RG_LOCATION
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_rule" "network_security_8080_rule" {
  count                       = var.ALLOW_8080
  name                        = "Allow8080"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.RG_NAME
}

resource "azurerm_network_security_rule" "network_security_80_rule" {
  count                       = var.ALLOW_80
  name                        = "Allow80"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.RG_NAME
}

resource "azurerm_network_security_rule" "network_security_ssh_rule" {
  count                       = var.ALLOW_22
  name                        = "AllowSSH"
  priority                    = 1003
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.SSH_PUBLIC_IP
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.RG_NAME
}

resource "azurerm_network_interface" "network_interface" {
  name                = "${var.APP_NAME}-${var.ENV_PREFIX}-nic"
  resource_group_name = var.RG_NAME
  location            = var.RG_LOCATION

  ip_configuration {
    name                          = "NIC-Config"
    subnet_id                     = var.SUBNET_ID
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id

  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic_sg_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "azure_VM" {
  name                  = "${var.APP_NAME}${var.ENV_PREFIX}VM"
  resource_group_name   = var.RG_NAME
  location              = var.RG_LOCATION
  network_interface_ids = [azurerm_network_interface.backend_nic.id]
  size                  = var.VM_SIZE

  os_disk {
    name                 = var.VM_OS_DISK
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "${var.APP_NAME}${var.ENV_PREFIX}VM"
  admin_username = var.SSH_USER

  admin_ssh_key {
    username   = var.SSH_USER
    public_key = var.PUBLIC_KEY
  }

  # Run the bash script
  # custom_data = base64encode(file("scripts/backendScript.sh"))

}
