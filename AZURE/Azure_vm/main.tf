provider "azurerm" {
    #version = "~>2.0"
    features {}
} 

resource "azurerm_resource_group" "az_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "az_vnet" {
    name        = var.virtual_network_name
    location    = var.location
    resource_group_name     = var.resource_group_name
    address_space           = ["10.0.0.0/20"]

    tags = {
        environment = "Test"
    }

    depends_on = [azurerm_resource_group.az_rg]
}

resource "azurerm_subnet" "az_subnet" {
    name    =   var.subnet_name
    resource_group_name     =   var.resource_group_name
    virtual_network_name    =   azurerm_virtual_network.az_vnet.name
    address_prefix          =   "10.0.0.0/24"
    
}

resource "azurerm_public_ip" "az_ip" {
    name    =   var.public_ip_name
    location    =   var.location
    resource_group_name     =   var.resource_group_name
    allocation_method       =   "Static"
    ip_version              =   "IPv4"

    tags = {
        environment =   "Test"
    }

    depends_on = [azurerm_resource_group.az_rg]
}

resource "azurerm_network_security_group" "az_nsg" {
    name    =   var.network_security_group_name
    location    =   var.location
    resource_group_name =   var.resource_group_name

    security_rule {
    name = "For_SSH"
    priority = 100
    direction = "Inbound"
    access  =   "Allow"
    protocol    =   "TCP"
    source_port_range   =   "*"
    destination_port_range  =   "22"
    source_address_prefix   =   "*"
    destination_address_prefix  =   "*"
    }

    security_rule {
    name = "For_ICMP"
    priority = 110
    direction = "Inbound"
    access  =   "Allow"
    protocol    =   "ICMP"
    source_port_range   =   "*"
    destination_port_range  =   "*"
    source_address_prefix   =   "*"
    destination_address_prefix  =   "*"
    }

    security_rule {
    name = "For_HTTP"
    priority = 120
    direction = "Inbound"
    access  =   "Allow"
    protocol    =   "TCP"
    source_port_range   =   "80"
    destination_port_range  =   "80"
    source_address_prefix   =   "*"
    destination_address_prefix  =   "*"
    }

    depends_on = [azurerm_resource_group.az_rg]
}

resource "azurerm_network_interface" "az_nic" {
    name    =   var.network_interface_name
    location    =   var.location
    resource_group_name =   var.resource_group_name

    ip_configuration {
        name    =   var.ip_configuration_name
        subnet_id   =   azurerm_subnet.az_subnet.id
        private_ip_address_allocation   =   "Dynamic"
        public_ip_address_id    =   azurerm_public_ip.az_ip.id
    }

    tags = {
        environment =   "Test"
    }
}

resource "azurerm_network_interface_security_group_association" "az_association" {
    network_interface_id    =   azurerm_network_interface.az_nic.id
    network_security_group_id   =   azurerm_network_security_group.az_nsg.id
}



resource "azurerm_linux_virtual_machine" "az_vm" {

    name    =   var.linux_virtual_machine_name
    location    =   var.location
    resource_group_name     =   var.resource_group_name
    network_interface_ids   =   [azurerm_network_interface.az_nic.id]
    size     =   "Standard_DS1_v2"
    custom_data = filebase64("apache.sh")

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    
    computer_name  = "Sanjay-Computer"
    admin_username  =   "sanjay"
    admin_password  =   "password!9"
    

    disable_password_authentication = false

}



