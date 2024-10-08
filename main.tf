resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["${var.address_space}"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create subnet
resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["${var.internal_subnet}"]
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  count               = var.vm_count
  name                = "${var.prefix}-vm${count.index + 1}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

# Create application security group
resource "azurerm_application_security_group" "asg" {
  name                = "${var.prefix}-asg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Inbound access rule from internet
  security_rule {
    name                       = "Inbound-from-internet-all-ports-specific-IPs"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.internet_acl
    destination_address_prefix = "*"
  }
  
  # Outbound access rule to block all traffic between VMs themselves if needed
  security_rule {
    name                       = "Oubound-block-internal"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_application_security_group_ids      = ["${azurerm_application_security_group.asg.id}"]
    destination_application_security_group_ids = ["${azurerm_application_security_group.asg.id}"]
  }
}

# Create network interface
resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "${var.prefix}-vm${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "${var.prefix}-vm${count.index + 1}-nic-ip"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.public_ip.*.id, count.index)
  }
}

# Connect the network security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  count                     = var.vm_count
  network_interface_id      = element(azurerm_network_interface.main.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Connect the application security group to the network interface
resource "azurerm_network_interface_application_security_group_association" "example" {
  count                         = var.vm_count
  network_interface_id          = element(azurerm_network_interface.main.*.id, count.index)
  application_security_group_id = azurerm_application_security_group.asg.id
}

# Create virtual machines
resource "azurerm_windows_virtual_machine" "main" {
  count                 = var.vm_count
  name                  = "${var.prefix}-vm${count.index + 1}"
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  size                  = var.vm_size
  admin_username        = var.vm_user
  admin_password        = var.vm_password
  timezone              = var.vm_timezone
  network_interface_ids = ["${azurerm_network_interface.main.*.id[count.index]}"]
  
  source_image_reference {
    publisher = var.azure_publisher
    offer     = var.azure_offer
    sku       = var.azure_sku
    version   = var.azure_version
  }

  os_disk {
    name                 = "${var.prefix}-vm${count.index + 1}-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

/*
# Change default RDP 3389 port on VM if necessery
resource "azurerm_virtual_machine_extension" "change_rdp_port" {
  count                      = var.vm_count
  name                       = "${var.prefix}-vm${count.index + 1}-ext"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.main.*.id, count.index)
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"

  protected_settings = <<SETTINGS
    {
      "commandToExecute": "powershell -encodedCommand ${textencodebase64(file("${path.module}/rdp_port.ps1"), "UTF-16LE")}"
    }
  SETTINGS
}
*/