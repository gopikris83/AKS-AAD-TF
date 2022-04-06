##########################################################
# AKS Cluster custom role definition and role assignment
##########################################################
data "azurerm_subscription" "primary" {
}

data "azurerm_client_config" "client_config" {
}

data "azuread_service_principal" "aks-sp" {
  display_name = "AKSAADServer1"

  depends_on = [
    azuread_application.aksaadserver
  ]
}

resource "azurerm_role_definition" "aks-admin-role" {
  name        = "AKS Cluster Admin Role"
  scope       = data.azurerm_subscription.primary.id
  description = "Grants actions required to create and manage aks cluster"
  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourcegroups/read",
      "Microsoft.Resources/subscriptions/resourcegroups/write",
      "Microsoft.Resources/subscriptions/resourcegroups/delete",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/virtualNetworks/write",
      "Microsoft.Network/virtualNetworks/delete",
      "Microsoft.Network/virtualNetworks/subnets/read",
      "Microsoft.Network/virtualNetworks/subnets/write",
      "Microsoft.Network/virtualNetworks/subnets/delete",
      "Microsoft.Network/virtualNetworks/subnets/join/action",
      "Microsoft.Network/publicIPPrefixes/read",
      "Microsoft.Network/publicIPPrefixes/write",
      "Microsoft.Network/publicIPPrefixes/delete",
      "Microsoft.Network/publicIPPrefixes/join/action",
      "Microsoft.Authorization/roleAssignments/read",
      "Microsoft.Authorization/roleAssignments/write",
      "Microsoft.Authorization/roleAssignments/delete",
      "Microsoft.Resources/deployments/write",
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/write",
      "Microsoft.ContainerService/managedClusters/delete",
      "Microsoft.ContainerService/managedClusters/agentPools/read",
      "Microsoft.ContainerService/managedClusters/agentPools/write",
      "Microsoft.ContainerService/managedClusters/agentPools/delete",
      "Microsoft.ContainerService/managedClusters/listClusterAdminCredential/action",
      "Microsoft.OperationsManagement/solutions/read",
      "Microsoft.OperationsManagement/solutions/write",
      "Microsoft.OperationalInsights/workspaces/read",
      "Microsoft.OperationalInsights/workspaces/sharedkeys/read",
      "Microsoft.ContainerRegistry/registries/read"
    ]
    not_actions = []
  }
  assignable_scopes = [
    "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
  ]
}

resource "azurerm_role_assignment" "aks-role-admin-assignment" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.aks-admin-role.role_definition_resource_id
  principal_id       = azuread_group.aks_admins.id
}


resource "azurerm_role_definition" "aks-developer-role" {
  name        = "AKS Cluster Developer Role"
  scope       = data.azurerm_subscription.primary.id
  description = "Grants actions required to deploy the application in AKS Cluster"
  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action"
    ]
    not_actions = []
  }
  assignable_scopes = [
    "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
  ]
}

resource "azurerm_role_assignment" "aks-role-developer-assignment" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.aks-developer-role.role_definition_resource_id
  principal_id       = data.azuread_service_principal.aks-sp.id
}


# data "azurerm_client_config" "client_config" {
# }

# # Custom Role defintions for the AKS Cluster
# resource "azurerm_role_definition" "aks_cluster_create_role" {
#   name        = "aks-cluster-create-role"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Grants actions required to create and manage aks compute"
#   permissions {
#     actions = [
#       "Microsoft.Resources/subscriptions/resourcegroups/read",
#       "Microsoft.ContainerService/managedClusters/write",
#       "Microsoft.ContainerService/managedClusters/read",
#       "Microsoft.ContainerService/managedClusters/agentPools/write",
#       "Microsoft.ContainerService/managedClusters/agentPools/read"
#     ]
#     not_actions = []
#   }
#   assignable_scopes = [
#     "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
#   ]
# }

# resource "azurerm_role_assignment" "aks_cluster_create_role_assignment" {
#   #name               = "create-role-assignment"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.aks_cluster_create_role.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.client_config.object_id
# }

# resource "azurerm_role_definition" "aks-cluster-delete-role" {
#   name        = "aks-cluster-delete-role"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Grants actions required to delete an aks cluster"
#   permissions {
#     actions = [
#       "Microsoft.ContainerService/managedClusters/delete"
#     ]
#     not_actions = []
#   }
#   assignable_scopes = [
#     "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
#   ]
# }

# resource "azurerm_role_assignment" "aks-cluster-delete-role-assignment" {
#   #name               = "delete-role-assignment"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.aks-cluster-delete-role.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.client_config.object_id
# }

# resource "azurerm_role_definition" "aks-cluster-network-role" {
#   name        = "aks-cluster-network-role"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Can Join and AKS Cluster to a given vnet/subnet"
#   permissions {
#     actions = [
#       "Microsoft.Resources/subscriptions/resourcegroups/read",
#       "Microsoft.Network/virtualNetworks/subnets/join/action",
#       "Microsoft.Storage/*/read"
#     ]
#     not_actions = []
#   }
#   assignable_scopes = [
#     "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
#   ]
# }

# resource "azurerm_role_assignment" "aks-cluster-network-role-assignment" {
#   # name               = "network-role-assignment"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.aks-cluster-network-role.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.client_config.object_id
# }

# resource "azurerm_role_definition" "aks-cluster-rgdeployment-role" {
#   name        = "aks-cluster-rgdeployment-role"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Can join an AKS cluster to a log analytics workspace"
#   permissions {
#     actions = [
#       "Microsoft.Resources/deployments/write",
#       "Microsoft.Resources/deployments/read"
#     ]
#     not_actions = []
#   }
#   assignable_scopes = [
#     "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
#   ]
# }

# resource "azurerm_role_assignment" "aks-cluster-rgdeployment-role-assignment" {
#   # name               = "rgdeployment-assignment"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.aks-cluster-rgdeployment-role.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.client_config.object_id
# }

# resource "azurerm_role_definition" "aks-cluster-loganalytics-role" {
#   name        = "aks-cluster-loganalytics-role"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Can join an AKS cluster to a log analytics workspace"
#   permissions {
#     actions = [
#       "Microsoft.OperationalInsights/workspaces/sharedkeys/read",
#       "Microsoft.OperationsManagement/solutions/write"
#     ]
#     not_actions = []
#   }
#   assignable_scopes = [
#     "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
#   ]
# }

# resource "azurerm_role_assignment" "aks-cluster-loganalytics-role-assignment" {
#   #name               = "loganalytics-assignment"
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.aks-cluster-loganalytics-role.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.client_config.object_id
# }

# resource "azurerm_role_definition" "aks-deployment-read-role" {
#   name        = "AKS Deployment Reader"
#   scope       = data.azurerm_subscription.primary.id
#   description = "Lets you view all deployments in cluster/namespaces"
#   permissions {
#     actions = [
#       #"Microsoft.ContainerService/managedClusters/read"
#     ]
#     not_actions = []
#     data_actions = [
#       "Microsoft.ContainerService/managedClusters/namespaces/read",
#     ]
#   }
#   assignable_scopes = [
#     "/subscriptions/05668dbd-b4a9-47bf-9be0-f93a45c7ca62"
#   ]
# }

# resource "azurerm_role_assignment" "aks-deployment-read-role-assignment" {
#   scope              = data.azurerm_subscription.primary.id
#   role_definition_id = azurerm_role_definition.aks-deployment-read-role.role_definition_resource_id
#   principal_id       = data.azurerm_client_config.client_config.object_id
# }