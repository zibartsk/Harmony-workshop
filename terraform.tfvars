vm_count        = 1
location        = "North Europe"
prefix          = "HAR-LAB"
address_space   = "10.0.0.0/16"
internal_subnet = "10.0.1.0/24"
vm_size         = "Standard_B2s"
vm_user         = "adminuser"
vm_password     = "Cpwins123456!"
vm_timezone     = "W. Europe Standard Time"
azure_publisher = "MicrosoftWindowsDesktop"
azure_offer     = "Windows-10"
azure_sku       = "win10-22h2-pro"
azure_version   = "latest"
internet_acl    = ["1.2.3.4", "5.6.7.8/27"]
# to change RDP port from default 3389, edit rdp_port.ps1 file and enable resource azurerm_virtual_machine_extension
