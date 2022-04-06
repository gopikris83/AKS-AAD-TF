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

variable "prefix" {
  default = "aks-project-cluster"
}

variable "address_space" {
  default = "10.101.0.0/16"
}

variable "homepage_url" {
  default = "https://gopikrishna83gmail.onmicrosoft.com" # use your verified domain
}

variable "identifier_uris" {
  default = ["https://gopikrishna83gmail.onmicrosoft.com"] # use your verified domain
}

variable "redirect_uris" {
  default = ["https://gopikrishna83gmail.onmicrosoft.com/"] # use your verified domain
}
