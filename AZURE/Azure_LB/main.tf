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
    sku                     =   "Standard"

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
    source_port_range   =   "*"
    destination_port_range  =   "80"
    source_address_prefix   =   "*"
    destination_address_prefix  =   "*"
    }

    depends_on = [azurerm_resource_group.az_rg]
}

resource "azurerm_network_interface" "az_nic" {
    count   =   2
    name    =   "${var.network_interface_name}-${count.index}"
    location    =   var.location
    resource_group_name =   var.resource_group_name

    ip_configuration {
        name    =   var.ip_configuration_name
        subnet_id   =   azurerm_subnet.az_subnet.id
        private_ip_address_allocation   =   "Dynamic"
        #public_ip_address_id    =   azurerm_public_ip.az_ip.id
    }

    tags = {
        environment =   "Test"
    }
}

resource "azurerm_network_interface_security_group_association" "az_association" {
    count   =   2
    network_interface_id    =   "${element(azurerm_network_interface.az_nic.*.id, count.index)}"
    network_security_group_id   =   azurerm_network_security_group.az_nsg.id
}



resource "azurerm_linux_virtual_machine" "az_vm" {
    count   =   2
    name    =   "${var.linux_virtual_machine_name}-${count.index}"
    location    =   var.location
    resource_group_name     =   var.resource_group_name
    network_interface_ids   =   ["${element(azurerm_network_interface.az_nic.*.id, count.index)}"]
    size     =   "Standard_DS1_v2"
    custom_data = filebase64("${count.index  ==  0 ? "apache.sh" : "nginx.sh"}")  
    #("${var.apache}.sh")

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_disk {
        name              = "myOsDisk-${count.index}"
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }
    
    computer_name  = "Sanjay-Computer"
    admin_username  =   "sanjay"
    admin_password  =   "password!9"
    

    disable_password_authentication = false

}

resource "azurerm_lb" "az_lb" {
  name                = var.load_balancer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.load_balancer_frontend_ip_name
    public_ip_address_id = azurerm_public_ip.az_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "az_backend_pool" {
  loadbalancer_id = azurerm_lb.az_lb.id
  name            = var.load_balancer_backend_address_pool_name
}

resource "azurerm_lb_probe" "az_lb_probe" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.az_lb.id
  name                = "http-probe"
  protocol            = "TCP"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.az_lb.id
  name                           = "LBRuleforhttp"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.load_balancer_frontend_ip_name
  enable_floating_ip             =  false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.az_backend_pool.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.az_lb_probe.id

}



