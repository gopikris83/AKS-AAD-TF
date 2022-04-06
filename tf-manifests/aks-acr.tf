##########################################################
# AKS Azure Container Registry
##########################################################
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