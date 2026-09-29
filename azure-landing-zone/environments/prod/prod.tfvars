# ─────────────────────────────────────────────────────────────────────────────
# PROD Environment — terraform.tfvars
# Usage: terraform plan -var-file="../../environments/prod/prod.tfvars"
# ─────────────────────────────────────────────────────────────────────────────

subscription_id = "00000000-0000-0000-0000-000000000000" # <-- prod subscription ID
tenant_id       = "00000000-0000-0000-0000-000000000000"
environment     = "prod"
location        = "East US"

tags = {
  ManagedBy   = "Terraform"
  Environment = "prod"
  Project     = "AzureLandingZone"
  CostCenter  = "IT-Prod"
}

# ─── Resource Groups ──────────────────────────────────────────────────────────
resource_groups = {
  "rg_networking" = {
    name     = "rg-prod-networking"
    location = "East US"
    tags     = { Environment = "prod", Component = "networking" }
  },
  "rg_compute" = {
    name     = "rg-prod-compute"
    location = "East US"
    tags     = { Environment = "prod", Component = "compute" }
  },
  "rg_security" = {
    name     = "rg-prod-security"
    location = "East US"
    tags     = { Environment = "prod", Component = "security" }
  }
}

# ─── Virtual Networks ─────────────────────────────────────────────────────────
vnets = {
  "vnet_main" = {
    name                = "vnet-prod-main"
    location            = "East US"
    resource_group_name = "rg-prod-networking"
    address_space       = ["10.30.0.0/16"]
    dns_servers         = []
    tags                = { Environment = "prod", Component = "networking" }
  }
}

# ─── Subnets ──────────────────────────────────────────────────────────────────
subnets = {
  "snet_web" = {
    name                 = "snet-prod-web"
    resource_group_name  = "rg-prod-networking"
    virtual_network_name = "vnet-prod-main"
    address_prefixes     = ["10.30.1.0/24"]
    delegation           = null
  },
  "snet_app" = {
    name                 = "snet-prod-app"
    resource_group_name  = "rg-prod-networking"
    virtual_network_name = "vnet-prod-main"
    address_prefixes     = ["10.30.2.0/24"]
    delegation           = null
  },
  "snet_data" = {
    name                 = "snet-prod-data"
    resource_group_name  = "rg-prod-networking"
    virtual_network_name = "vnet-prod-main"
    address_prefixes     = ["10.30.3.0/24"]
    delegation           = null
  },
  "AzureBastionSubnet" = {
    name                 = "AzureBastionSubnet"
    resource_group_name  = "rg-prod-networking"
    virtual_network_name = "vnet-prod-main"
    address_prefixes     = ["10.30.4.0/27"]
    delegation           = null
  }
}

# ─── NSGs ─────────────────────────────────────────────────────────────────────
nsgs = {
  "nsg_web" = {
    name                = "nsg-prod-web"
    location            = "East US"
    resource_group_name = "rg-prod-networking"
    subnet_key          = "snet_web"
    tags                = { Environment = "prod" }
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
      },
      {
        name                       = "Deny-All-Inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  },
  "nsg_app" = {
    name                = "nsg-prod-app"
    location            = "East US"
    resource_group_name = "rg-prod-networking"
    subnet_key          = "snet_app"
    tags                = { Environment = "prod" }
    security_rules = [
      {
        name                       = "Allow-Web-To-App"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "10.30.1.0/24"
        destination_address_prefix = "*"
      }
    ]
  },
  "nsg_data" = {
    name                = "nsg-prod-data"
    location            = "East US"
    resource_group_name = "rg-prod-networking"
    subnet_key          = "snet_data"
    tags                = { Environment = "prod" }
    security_rules = [
      {
        name                       = "Allow-App-To-DB"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "10.30.2.0/24"
        destination_address_prefix = "*"
      },
      {
        name                       = "Deny-All-Inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

# ─── Route Tables ─────────────────────────────────────────────────────────────
route_tables = {
  "rt_web" = {
    name                          = "rt-prod-web"
    location                      = "East US"
    resource_group_name           = "rg-prod-networking"
    disable_bgp_route_propagation = false
    subnet_key                    = "snet_web"
    tags                          = { Environment = "prod" }
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
    name                = "pip-prod-bastion"
    location            = "East US"
    resource_group_name = "rg-prod-networking"
    allocation_method   = "Static"
    sku                 = "Standard"
    zones               = ["1", "2", "3"]
    tags                = { Environment = "prod" }
  }
}

# ─── NICs ─────────────────────────────────────────────────────────────────────
nics = {}

# ─── Virtual Machines ─────────────────────────────────────────────────────────
vms = {}

# ─── Key Vaults ───────────────────────────────────────────────────────────────
key_vaults = {
  "kv_main" = {
    name                       = "kv-prod-lz"
    location                   = "East US"
    resource_group_name        = "rg-prod-security"
    sku_name                   = "premium"
    soft_delete_retention_days = 90
    purge_protection_enabled   = true
    enable_rbac_authorization  = true
    tags                       = { Environment = "prod" }
    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
    access_policies = []
  }
}

# ─── Bastion ──────────────────────────────────────────────────────────────────
bastions = {
  "bastion_main" = {
    name                 = "bastion-prod-main"
    location             = "East US"
    resource_group_name  = "rg-prod-networking"
    sku                  = "Standard"
    subnet_id            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/virtualNetworks/vnet-prod-main/subnets/AzureBastionSubnet"
    public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-prod-networking/providers/Microsoft.Network/publicIPAddresses/pip-prod-bastion"
    tags                 = { Environment = "prod" }
  }
}
