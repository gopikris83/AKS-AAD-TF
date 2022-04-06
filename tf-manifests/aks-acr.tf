##########################################################
# AKS Azure Container Registry
##########################################################
# data "azurerm_resource_group" "aks_rg" {
#   name = "${var.resource_group_name}-${var.environment}"
# }

resource "azurerm_container_registry" "aks-acr" {
  name                = "terraformaksacr"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Standard"
  admin_enabled       = false

  tags = {
    Name        = var.resource_group_name
    Environment = var.environment
  }
}

# resource "azurerm_container_registry_scope_map" "example" {
#   name                    = "aks-scope-map"
#   container_registry_name = azurerm_container_registry.aks-acr.name
#   resource_group_name     = azurerm_resource_group.aks_rg.name
#   actions = [
#     "repositories/repo1/content/read",
#     "repositories/repo1/content/write"
#   ]
# }

# Role Assignment for the Container registry for AKS to pull images
# data "azurerm_container_registry" "data_acr" {
#   name                = "terraformaksacr"
#   resource_group_name = data.azurerm_resource_group.aks_rg.name
# }

data "azuread_service_principal" "akssp" {
  display_name = "AKSAADServer1"

  depends_on = [
    azuread_application.aksaadserver,
    azuread_application.aksaadclient
  ]
}

resource "azurerm_role_assignment" "aks_to_acr_role" {
  principal_id                     = data.azuread_service_principal.akssp.object_id
  scope                            = azurerm_container_registry.aks-acr.id
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
}