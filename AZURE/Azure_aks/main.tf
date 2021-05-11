provider "azurerm" {
   features {}
}

resource "azurerm_kubernetes_cluster" "az_cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "sanjay-demo001"

  default_node_pool {
    name       = "myagentpool"
    node_count = 2  
    vm_size    = "Standard_DS2_v2"
    
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Test"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.az_cluster.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.az_cluster.kube_config_raw
}