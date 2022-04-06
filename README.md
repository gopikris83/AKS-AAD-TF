# Azure Kubernetes Service with Azure Active Directory Integration - Terraform

Simple AKS Cluster provisioning with AAD using Terraform. 

There is also log analytics enabled to monitor the AKS Cluster deployments.

For more details on Terraform : https://www.terraform.io/


![AKS-AAD-TF](/aksaad.png)


## What is deployed ?

Things that are deployed as part of [Terraform] :

Application container deployed to print User-Agent Info

* Azure Active Directory Service Principal App (Server and Client)
* Azure Container Registry for conatiner images repository
* Azure Kubernetes services using service principal as identity
* Default node pool having Windows and Linux agents
* Azure Storage for storing the terraform state file
* Azure Resource groups for AKS Cluster and AKS Nodes
* Azure Active Directory Groups (Manage SRE and Developer members using Azure RBAC with Kubernetes RBAC)
* Includes Terraform Manifests for AKS Spinup and Kubernetes manifests for deployments also roles, role bindings to manage the kube RBAC

### Install dependencies

* [`Python`](https://www.python.org/downloads/) Refer the link
* [`Docker`](https://docs.docker.com/engine/install/) Refer the link
* [`terraform`](https://learn.hashicorp.com/tutorials/terraform/install-cli) required for `terraform deploy`.
* [`kubectl`](https://kubernetes.io/docs/tasks/tools/) Refer the link

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>2.63 |

## Usage

Backend is created using Azure Storage to store the terraform state file.

* Image push to ACR

```
az acr login

docker login loginServer(Azure container registry) -u Username and -p Password

```
ACR Access key can be retrieved by enabling the Admin User
Assuming images are pushed to ACR repo. 


# Grant permissions for the Service principal Server App for the applications to call the Kubernetes API's from Azure through the process of consent

![Grant Admin Consent](/grantapipermission.png)

Make sure that AKSAADServer1 app has public client enabled.
```
Under AKSAADServer1 blade --> Manifests

"allowPublicClient": true
```

* Create Users for AD Groups (SRE and Developer). Add these users under respective groups. 

For more information - [`AD user creation`](https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/create-an-active-directory-server)

* Init/Plan/Apply

### Init, Plan and Apply changes
```
# Run terraform to initialize, plan (preview the infrastructure) and apply for provisioning.

terraform init

terraform plan

terraform apply

# Finally, destroy all infrastructure using terraform destroy

terraform destroy
```
