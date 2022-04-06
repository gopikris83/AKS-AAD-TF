##########################################################
# Service Principal for AKS (Server and Client)
##########################################################
data "azuread_application_published_app_ids" "well_known" {}

resource "random_uuid" "widget_scope_id" {}

# Configuration for SP Server app
resource "azuread_application" "aksaadserver" {
  display_name                   = "AKSAADServer1"
  identifier_uris                = var.identifier_uris
  fallback_public_client_enabled = true

  required_resource_access {
    #Get Microsoft Graph (00000003-0000-0000-c000-000000000000)
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
    resource_access {
      id   = "06da0dbc-49e2-44d2-8312-53f166ab848a"
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
  }

  required_resource_access {
    # Get the Azure Active Directory Graph (00000002-0000-0000-c000-000000000000)
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.AzureActiveDirectoryGraph
    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }

  web {
    homepage_url  = var.homepage_url
    redirect_uris = var.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access example on behalf of the signed-in user."
      admin_consent_display_name = "Access AKSAADServer1"
      enabled                    = true
      id                         = random_uuid.widget_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access example on your behalf."
      user_consent_display_name  = "Access AKSAADServer1"
      value                      = "user_impersonation"
    }
  }

}


resource "azuread_service_principal" "aksaadsp" {
  application_id = azuread_application.aksaadserver.application_id
}

resource "azuread_application_password" "aks-aad-pwd" {
  application_object_id = azuread_application.aksaadserver.object_id
  end_date              = "2024-01-01T01:02:03Z"
}

# OAuth2Permission scope retrieval from Server App
data "azuread_application" "aksadapp-datasrc" {
  application_id = azuread_application.aksaadserver.application_id
}

locals {
  scope_id = data.azuread_application.aksadapp-datasrc.oauth2_permission_scope_ids
}

# Configuration for SP Client
resource "azuread_application" "aksaadclient" {
  display_name = "AKSAADClient1"

  required_resource_access {
    resource_app_id = azuread_application.aksaadserver.application_id

    resource_access {
      id   = lookup(local.scope_id, "user_impersonation")
      type = "Scope"
    }
  }

  web {
    homepage_url  = "https://aksaadclient1"
    redirect_uris = ["https://aksaadclient1/"]

    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access AKSAADClient1 on behalf of the signed-in user."
      admin_consent_display_name = "Access AKSAADClient1"
      enabled                    = true
      id                         = random_uuid.widget_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access AKSAADClient3 on your behalf."
      user_consent_display_name  = "Access AKSAADClient1"
      value                      = "user_impersonation"
    }
  }
}
