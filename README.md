# Terraform

## Credentials for access to the API provider

Create a file in this folder : credential.auto.tfvars

```
proxmox_api_url = "https://$URL/api2/json"
proxmox_api_token_id = "$USER@$AUTH!terraform"
proxmox_api_token_secret = "$SECRET"
```

## Terraform init

Go to the terminal to init the connection with the provider :

```
$ terraform init
```

## Terraform plan

Show changes :

```
$ terraform plan
```

## Terraform apply

Apply configuration with auto approve

```
$ terraform apply --auto-approve
```