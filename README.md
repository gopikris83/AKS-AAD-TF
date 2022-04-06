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

## Access the Cluster
Make sure that Users are created in AD and mapped to the respective AD Groups for the Azure RBAC and Kubernetes RBAC to work like a charm.

Get the cluster credentials
```
$ az aks get-credentials --resource-group <RESOURCE_GROUP> -n <CLUSTER_NAME>
```
Run the kubectl commands for the client to authenticate to the Kubernetes API via AD. 

```
$ kubectl get nodes
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code DP9JA76WS to authenticate.

```
Error from server (Forbidden): nodes is forbidden: User "593736cb-1f95-4f23-bfbd-75891886b05f" cannot list resource "nodes" in API group "" at the cluster scope

Great! Expected error as Kubernetes cluter has insufficient permissions at Kube RBAC level.

Now, Add the Group ID (Object ID) obtained from AD Groups to the Rolebindings of the yaml file located under Kube-manifests directory. 

Ex: SRE Group ID should be added to Cluster Role Binding and SRE role binding yaml files as shown

```
- kind: Group
  name: 2b59f902-709b-475c-940d-6d60499a6f02 # "name" is case sensitive
  apiGroup: rbac.authorization.k8s.io
```
Same goes with Developer Group ID to Dev role binding yaml files to refelct the correct RBAC permissions set for the users groups.

Use the below credentials to deploy the Kubernetes manifests using your administrative priviledges

```
$ az aks get-credentials --resource-group <RESOURCE_GROUP> -n <CLUSTER_NAME> --overwrite-existing --admin

kubectl create -f kube-manifests/

```
After kubernetes manifests deployments, try running the kubect commands using different user clients (SRE and Developer) to see the access restrictions for the Kubernetes API's or Clusters



