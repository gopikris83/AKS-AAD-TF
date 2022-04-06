##########################################################
# Input variables
##########################################################
variable "resource_group_name" {
  type        = string
  description = "Azure Resource group name"
  default     = "aks-project-cluster"
}

variable "environment" {
  type        = string
  description = "AKS hosted environment"
  default     = "test"
}

variable "location" {
  type        = string
  description = "Region of Azure resources provisioned"
  default     = "Sweden Central"
}

variable "ssh_pub_key" {
  default     = "~/.ssh/aks-terraform-sshkeys/akspubkey.pub"
  description = "This variable defines the SSH Public Key for Linux k8s Worker nodes"
}

variable "win_admin_username" {
  type    = string
  default = "azureuser"
}

variable "win_admin_password" {
  type    = string
  default = "P@ssw0rd19800402"
}

# variable "client_app_id" {
#   description = "The Client app ID of the AKS client application"
# }

# variable "client_app_secret" {
#   description = "The secret created for AKS server application"
# }

variable "prefix" {
  default = "aks-project-cluster"
}

variable "address_space" {
  default = "10.101.0.0/16"
}

# variable "server_app_id" {
#   description = "AKS Client App ID"
# }

# variable "serverappid" {
#   description = "AKS Server app id"
# }

# variable "serverappsecret" {
#   description = "AKS Server Secret"
# }

# variable "tenantid" {
#   description = "Azure Tenant id"
# }

variable "resource_id" {
  type    = list(string)
  default = ["00000003-0000-0000-c000-000000000000", "00000002-0000-0000-c000-000000000000"]
}

variable "scopes" {
  type    = list(string)
  default = ["User.Read", "Directory.Read.All", "user_impersonation"]
}

variable "homepage_url" {
  default = "https://gopikrishna83gmail.onmicrosoft.com"
}

variable "identifier_uris" {
  default = ["https://gopikrishna83gmail.onmicrosoft.com"]
}

variable "redirect_uris" {
  default = ["https://gopikrishna83gmail.onmicrosoft.com/"]
}
