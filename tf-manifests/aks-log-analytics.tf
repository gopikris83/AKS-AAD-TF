##########################################################
# AKS Log Analytics
##########################################################
resource "azurerm_log_analytics_workspace" "logs_insights" {
  name                = "${var.resource_group_name}-logs-analytics"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  retention_in_days   = 30
}
