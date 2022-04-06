output "location" {
  value = azurerm_resource_group.aks_rg.location
}

output "varsions" {
  value = data.azurerm_kubernetes_service_versions.current.versions
}

output "latest_version" {
  value = data.azurerm_kubernetes_service_versions.current.latest_version
}

output "azure_ad_group_id" {
  value = azuread_group.aks_admins.id
}

output "azure_ad_group_objectid" {
  value = azuread_group.aks_admins.object_id
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_cluster_kubernetes_version" {
  value = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}

output "acr-role" {
  value = azurerm_role_assignment.aks_to_acr_role.id
}

