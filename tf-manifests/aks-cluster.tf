##########################################################
# AKS Cluster resources
##########################################################

data "azuread_application" "serverapp-ds" {
  display_name = "AKSAADServer1"

  depends_on = [
    azuread_application.aksaadserver
  ]
}

# data "azuread_application_password" "client_secret" {
#   application_id = data.azuread_application.serverapp-ds.application_id
# }

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

# resource "azurerm_virtual_network" "aks-vn" {
#   name                = "${var.prefix}-network"
#   location            = azurerm_resource_group.aks_rg.location
#   resource_group_name = azurerm_resource_group.aks_rg.name
#   address_space       = [var.address_space]
# }

# resource "azurerm_subnet" "aks-subnet" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.aks_rg.name
#   address_prefixes     = ["10.101.0.0/24"]
#   virtual_network_name = azurerm_virtual_network.aks-vn.name
# }

# AKS Server App
# resource "azuread_application" "aks-aad-svr" {
#   display_name = "${var.prefix}svr"
#   #group_membership_claims = "All"

#   required_resource_access {
#     resource_app_id = "00000003-0000-0000-c000-000000000000"
#     resource_access {
#       id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
#       type = "Scope"
#     }
#     resource_access {
#       id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
#       type = "Scope"
#     }
#     resource_access {
#       id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
#       type = "Role"
#     }
#   }
#   required_resource_access {
#     resource_app_id = "00000002-0000-0000-c000-000000000000"
#     resource_access {
#       id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
#       type = "Scope"
#     }
#   }
#   web {
#     homepage_url  = "https://${var.prefix}"
#     redirect_uris = ["https://${var.prefix}/"]
#   }
# }

# resource "azuread_service_principal" "aks-aad-sp" {
#   application_id = azuread_application.aks-aad-svr.application_id
# }

# resource "random_password" "aks-aad-random_password" {
#   length  = 16
#   special = true
# }

# resource "azuread_application_password" "aks-aad-pwd" {
#   application_object_id = azuread_application.aks-aad-svr.object_id
#   #value                 = random_password.aks-aad-random_password.result
#   end_date = "2024-01-01T01:02:03Z"
# }

# # AKS Client App
# resource "azuread_application" "aks-aad-client" {
#   display_name = "${var.prefix}client"
#   #type         = "native"
#   required_resource_access {
#     resource_app_id = azuread_application.aks-aad-svr.application_id
#     resource_access {
#       id   = azuread_application.aks-aad-svr.id
#       type = "Scope"
#     }
#   }
#   web {
#     homepage_url  = "https://${var.prefix}"
#     redirect_uris = ["https://${var.prefix}/"]
#   }
# }

# resource "azuread_service_principal" "aks-aad-client-sp" {
#   application_id = azuread_application.aks-aad-client.application_id
# }

# # Grant permissions
# resource "null_resource" "delay_before_consent" {
#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
#   depends_on = [
#     azuread_service_principal.aks-aad-sp,
#     azuread_service_principal.aks-aad-client-sp
#   ]
# }

# resource "null_resource" "grant_srv_admin_constent" {
#   provisioner "local-exec" {
#     command = "az ad app permission admin-consent --id ${azuread_application.aks-aad-svr.application_id}"
#   }
#   depends_on = [
#     null_resource.delay_before_consent
#   ]
# }

# resource "null_resource" "grant_client_admin_constent" {
#   provisioner "local-exec" {
#     command = "az ad app permission admin-consent --id ${azuread_application.aks-aad-client.application_id}"
#   }
#   depends_on = [
#     null_resource.delay_before_consent
#   ]
# }

# resource "null_resource" "delay" {
#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
#   depends_on = [
#     null_resource.grant_srv_admin_constent,
#     null_resource.grant_client_admin_constent
#   ]
# }