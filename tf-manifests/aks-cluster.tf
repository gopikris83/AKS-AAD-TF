##########################################################
# AKS Cluster resources
##########################################################

data "azuread_application" "serverapp-ds" {
  display_name = "AKSAADServer1"

  depends_on = [
    azuread_application.aksaadserver
  ]
}

data "azurerm_subscription" "current" {
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  dns_prefix          = azurerm_resource_group.aks_rg.name
  name                = var.resource_group_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"

  default_node_pool {
    name                 = "aksnodepool"
    vm_size              = "Standard_D3_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    max_count            = 4
    min_count            = 2
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    # vnet_subnet_id       = azurerm_subnet.aks-subnet.id
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }

  # Identity either SystemAssigned or UserAssigned
  #identity { type = "SystemAssigned" }

  addon_profile {
    azure_policy { enabled = true }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.logs_insights.id
    }
  }

  # Azure Active Directory enabled with RBAC within AKS CLuster
  azure_active_directory_role_based_access_control {
    managed           = false # Managed Identity set false (Using Service principal for identity)
    client_app_id     = data.azuread_application.serverapp-ds.application_id
    server_app_id     = data.azuread_application.serverapp-ds.application_id
    server_app_secret = azuread_application_password.aks-aad-pwd.value
    tenant_id         = data.azurerm_subscription.current.tenant_id
  }
  # Setting Windows profile for Windows node pools
  windows_profile {
    admin_username = var.win_admin_username
    admin_password = var.win_admin_password
  }
  # Setting Linux profile for linux node pools
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_pub_key)
    }
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "azure"
    network_policy    = "calico" # Using builtin Calico for network policy
  }
  # Credentials for Service Pricipal (Server app)
  service_principal {
    client_id     = data.azuread_application.serverapp-ds.application_id
    client_secret = azuread_application_password.aks-aad-pwd.value
  }


  tags = {
    Environment = var.environment
  }
  depends_on = [
    azuread_application.aksaadserver,
    azuread_application.aksaadclient
  ]
}
