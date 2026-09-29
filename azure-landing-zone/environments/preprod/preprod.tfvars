# ─────────────────────────────────────────────────────────────────────────────
# PRE-PROD Environment — terraform.tfvars
# Usage: terraform plan -var-file="../../environments/preprod/preprod.tfvars"
# ─────────────────────────────────────────────────────────────────────────────

subscription_id = "00000000-0000-0000-0000-000000000000" # <-- preprod subscription ID
tenant_id       = "00000000-0000-0000-0000-000000000000"
environment     = "preprod"
location        = "East US"

tags = {
  ManagedBy   = "Terraform"
  Environment = "preprod"
  Project     = "AzureLandingZone"
  CostCenter  = "IT-PreProd"
}

# ─── Resource Groups ──────────────────────────────────────────────────────────
resource_groups = {
  "rg_networking" = {
    name     = "rg-preprod-networking"
    location = "East US"
    tags     = { Environment = "preprod", Component = "networking" }
  },
  "rg_compute" = {
    name     = "rg-preprod-compute"
    location = "East US"
    tags     = { Environment = "preprod", Component = "compute" }
  },
  "rg_security" = {
    name     = "rg-preprod-security"
    location = "East US"
    tags     = { Environment = "preprod", Component = "security" }
  }
}

# ─── Virtual Networks ─────────────────────────────────────────────────────────
vnets = {
  "vnet_main" = {
    name                = "vnet-preprod-main"
    location            = "East US"
    resource_group_name = "rg-preprod-networking"
    address_space       = ["10.20.0.0/16"]
    dns_servers         = []
    tags                = { Environment = "preprod", Component = "networking" }
  }
}

# ─── Subnets ──────────────────────────────────────────────────────────────────
subnets = {
  "snet_web" = {
    name                 = "snet-preprod-web"
    resource_group_name  = "rg-preprod-networking"
    virtual_network_name = "vnet-preprod-main"
    address_prefixes     = ["10.20.1.0/24"]
    delegation           = null
  },
  "snet_app" = {
    name                 = "snet-preprod-app"
    resource_group_name  = "rg-preprod-networking"
    virtual_network_name = "vnet-preprod-main"
    address_prefixes     = ["10.20.2.0/24"]
    delegation           = null
  },
  "snet_data" = {
    name                 = "snet-preprod-data"
    resource_group_name  = "rg-preprod-networking"
    virtual_network_name = "vnet-preprod-main"
    address_prefixes     = ["10.20.3.0/24"]
    delegation           = null
  },
  "AzureBastionSubnet" = {
    name                 = "AzureBastionSubnet"
    resource_group_name  = "rg-preprod-networking"
    virtual_network_name = "vnet-preprod-main"
    address_prefixes     = ["10.20.4.0/27"]
    delegation           = null
  }
}

# ─── NSGs ─────────────────────────────────────────────────────────────────────
nsgs = {
  "nsg_web" = {
    name                = "nsg-preprod-web"
    location            = "East US"
    resource_group_name = "rg-preprod-networking"
    subnet_key          = "snet_web"
    tags                = { Environment = "preprod" }
    security_rules = [
      {
        name                       = "Allow-HTTPS-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
    ]
  }
}

# ─── Route Tables ─────────────────────────────────────────────────────────────
route_tables = {
  "rt_web" = {
    name                          = "rt-preprod-web"
    location                      = "East US"
    resource_group_name           = "rg-preprod-networking"
    disable_bgp_route_propagation = false
    subnet_key                    = "snet_web"
    tags                          = { Environment = "preprod" }
    routes = [
      {
        name                   = "route-to-internet"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      }
    ]
  }
}

# ─── Public IPs ───────────────────────────────────────────────────────────────
public_ips = {
  "pip_bastion" = {
    name                = "pip-preprod-bastion"
    location            = "East US"
    resource_group_name = "rg-preprod-networking"
    allocation_method   = "Static"
    sku                 = "Standard"
    zones               = []
    tags                = { Environment = "preprod" }
  }
}

# ─── NICs ─────────────────────────────────────────────────────────────────────
nics = {}

# ─── Virtual Machines ─────────────────────────────────────────────────────────
vms = {}

# ─── Key Vaults ───────────────────────────────────────────────────────────────
key_vaults = {
  "kv_main" = {
    name                       = "kv-preprod-lz"
    location                   = "East US"
    resource_group_name        = "rg-preprod-security"
    sku_name                   = "standard"
    soft_delete_retention_days = 14
    purge_protection_enabled   = true
    enable_rbac_authorization  = true
    tags                       = { Environment = "preprod" }
    network_acls               = null
    access_policies            = []
  }
}

# ─── Bastion ──────────────────────────────────────────────────────────────────
bastions = {
  "bastion_main" = {
    name                 = "bastion-preprod-main"
    location             = "East US"
    resource_group_name  = "rg-preprod-networking"
    sku                  = "Basic"
    subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-preprod-networking/providers/Microsoft.Network/virtualNetworks/vnet-preprod-main/subnets/AzureBastionSubnet"
    public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-preprod-networking/providers/Microsoft.Network/publicIPAddresses/pip-preprod-bastion"
    tags                 = { Environment = "preprod" }
  }
}
