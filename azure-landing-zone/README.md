# Azure Landing Zone — Terraform (for_each + map pattern)

## Structure

```
azure-landing-zone/
├── parent-module/          # Root module — sab child modules ko call karta hai
├── child-modules/          # Reusable modules (rg, vnet, subnet, nsg, rt, pip, nic, vm, kv, bastion)
└── environments/
    ├── dev/dev.tfvars
    ├── preprod/preprod.tfvars
    └── prod/prod.tfvars
```

## Terraform Plan Steps

### 1. Directory mein jao
```powershell
cd azure-landing-zone/parent-module
```

### 2. Init karo
```powershell
terraform init
```

### 3. Plan — Dev
```powershell
terraform plan -var-file="../environments/dev/dev.tfvars"
```

### 4. Plan — PreProd
```powershell
terraform plan -var-file="../environments/preprod/preprod.tfvars"
```

### 5. Plan — Prod
```powershell
terraform plan -var-file="../environments/prod/prod.tfvars"
```

### 6. Apply (subscription milne ke baad)
```powershell
terraform apply -var-file="../environments/dev/dev.tfvars"
```

## Subscription ID kahan update karein

Har environment ke tfvars mein yeh do values replace karo:
```hcl
subscription_id = "YOUR-ACTUAL-SUBSCRIPTION-ID"
tenant_id       = "YOUR-ACTUAL-TENANT-ID"
```

## IP Address Ranges (Environment wise)

| Environment | VNet CIDR     | Web Subnet    | App Subnet    | Data Subnet   | Bastion       |
|-------------|---------------|---------------|---------------|---------------|---------------|
| dev         | 10.10.0.0/16  | 10.10.1.0/24  | 10.10.2.0/24  | 10.10.3.0/24  | 10.10.4.0/27  |
| preprod     | 10.20.0.0/16  | 10.20.1.0/24  | 10.20.2.0/24  | 10.20.3.0/24  | 10.20.4.0/27  |
| prod        | 10.30.0.0/16  | 10.30.1.0/24  | 10.30.2.0/24  | 10.30.3.0/24  | 10.30.4.0/27  |

## for_each + map Pattern

Har child module `for_each` use karta hai map variable ke upar:

```hcl
# Child module mein
resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups   # map iterate karta hai
  name     = each.value.name
  location = each.value.location
}

# Parent module mein call
module "resource_group" {
  source          = "../child-modules/resource-group"
  resource_groups = var.resource_groups   # map pass karta hai
}

# tfvars mein define
resource_groups = {
  "rg_networking" = { name = "rg-dev-networking", location = "East US", tags = {} }
  "rg_compute"    = { name = "rg-dev-compute",    location = "East US", tags = {} }
}
```
