##########################################################
# AKS Cluster resources
# AD Group for SRE
# AD Group for Developers
##########################################################
resource "azuread_group" "aks_admins" {
  #name             = "${azurerm_resource_group.aks_rg.name}-${var.environment}-admins"
  display_name     = "${azurerm_resource_group.aks_rg.name}-sre-adgroup"
  description      = "Azure AKS Administrators for ${azurerm_resource_group.aks_rg.name}-${var.environment} cluster"
  security_enabled = true
}


resource "azuread_group" "aks_developers" {
  #name             = "${azurerm_resource_group.aks_rg.name}-${var.environment}-admins"
  display_name     = "${azurerm_resource_group.aks_rg.name}-dev-adgroup"
  description      = "Azure AKS Developers for ${azurerm_resource_group.aks_rg.name}-${var.environment} cluster"
  security_enabled = true
}