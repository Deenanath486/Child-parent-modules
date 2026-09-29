# ─────────────────────────────────────────────────────────────────────────────
# DEV Environment — terraform.tfvars
# Usage: terraform plan -var-file="../environments/dev/dev.tfvars"
# ─────────────────────────────────────────────────────────────────────────────

subscription_id = "cc6eb6b0-ec2f-4e39-9a40-37a2b2ea1ba8"
tenant_id       = "f6711f40-0336-4f89-b850-b110a56df7d1"
environment     = "dev"
location        = "East US"

tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  Project     = "AzureLandingZone"
  CostCenter  = "IT-Dev"
  Owner       = "Devyani"
}

# ─── Resource Groups ──────────────────────────────────────────────────────────
resource_groups = {
  "rg_networking" = {
    name     = "dvyn-dev-networking-rg"
    location = "East US"
    tags     = { Environment = "dev", Component = "networking" }
  },
  "rg_compute" = {
    name     = "dvyn-dev-compute-rg"
    location = "East US"
    tags     = { Environment = "dev", Component = "compute" }
  },
  "rg_security" = {
    name     = "dvyn-dev-security-rg"
    location = "East US"
    tags     = { Environment = "dev", Component = "security" }
  },
  "rg_devyani1" = {
    name     = "Devyani1-RG"
    location = "East US"
    tags     = { Environment = "dev", Component = "devyani1", Owner = "Devyani" }
  }
}

# ─── Virtual Networks ─────────────────────────────────────────────────────────
vnets = {
  "vnet_main" = {
    name                = "dvyn-dev-vnet-001"
    location            = "East US"
    resource_group_name = "dvyn-dev-networking-rg"
    address_space       = ["10.10.0.0/16"]
    dns_servers         = []
    tags                = { Environment = "dev", Component = "networking" }
  }
}

# ─── Subnets ──────────────────────────────────────────────────────────────────
subnets = {
  "snet_web" = {
    name                 = "dvyn-dev-snet-web"
    resource_group_name  = "dvyn-dev-networking-rg"
    virtual_network_name = "dvyn-dev-vnet-001"
    address_prefixes     = ["10.10.1.0/24"]
    delegation           = null
  },
  "snet_app" = {
    name                 = "dvyn-dev-snet-app"
    resource_group_name  = "dvyn-dev-networking-rg"
    virtual_network_name = "dvyn-dev-vnet-001"
    address_prefixes     = ["10.10.2.0/24"]
    delegation           = null
  },
  "snet_data" = {
    name                 = "dvyn-dev-snet-data"
    resource_group_name  = "dvyn-dev-networking-rg"
    virtual_network_name = "dvyn-dev-vnet-001"
    address_prefixes     = ["10.10.3.0/24"]
    delegation           = null
  },
  "AzureBastionSubnet" = {
    name                 = "AzureBastionSubnet"
    resource_group_name  = "dvyn-dev-networking-rg"
    virtual_network_name = "dvyn-dev-vnet-001"
    address_prefixes     = ["10.10.4.0/27"]
    delegation           = null
  }
}

# ─── NSGs ─────────────────────────────────────────────────────────────────────
nsgs = {
  "nsg_web" = {
    name                = "dvyn-dev-nsg-web"
    location            = "East US"
    resource_group_name = "dvyn-dev-networking-rg"
    subnet_key          = "snet_web"
    tags                = { Environment = "dev", Component = "networking" }
    security_rules = [
      {
        name                       = "Allow-HTTP-Inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow-HTTPS-Inbound"
        priority                   = 110
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
    name                = "dvyn-dev-nsg-app"
    location            = "East US"
    resource_group_name = "dvyn-dev-networking-rg"
    subnet_key          = "snet_app"
    tags                = { Environment = "dev", Component = "networking" }
    security_rules = [
      {
        name                       = "Allow-Web-To-App"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "10.10.1.0/24"
        destination_address_prefix = "*"
      }
    ]
  }
}

# ─── Route Tables ─────────────────────────────────────────────────────────────
route_tables = {
  "rt_web" = {
    name                          = "dvyn-dev-rt-web"
    location                      = "East US"
    resource_group_name           = "dvyn-dev-networking-rg"
    disable_bgp_route_propagation = false
    subnet_key                    = "snet_web"
    tags                          = { Environment = "dev" }
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
    name                = "dvyn-dev-pip-bastion"
    location            = "East US"
    resource_group_name = "dvyn-dev-networking-rg"
    allocation_method   = "Static"
    sku                 = "Standard"
    zones               = []
    tags                = { Environment = "dev", Component = "bastion" }
  }
}

# ─── Virtual Machines ─────────────────────────────────────────────────────────
# VM baad mein add karo jab SSH key ready ho
vms = {}

# ─── NICs ─────────────────────────────────────────────────────────────────────
nics = {}

# ─── Key Vaults ───────────────────────────────────────────────────────────────
key_vaults = {
  "kv_main" = {
    name                       = "dvyn-dev-kv-lz001"
    location                   = "East US"
    resource_group_name        = "dvyn-dev-security-rg"
    sku_name                   = "standard"
    soft_delete_retention_days = 7
    purge_protection_enabled   = false
    enable_rbac_authorization  = true
    tags                       = { Environment = "dev", Component = "security" }
    network_acls               = null
    access_policies            = []
  }
}

# ─── Bastion ──────────────────────────────────────────────────────────────────
bastions = {
  "bastion_main" = {
    name                 = "dvyn-dev-bastion-001"
    location             = "East US"
    resource_group_name  = "dvyn-dev-networking-rg"
    sku                  = "Basic"
    subnet_id            = "/subscriptions/cc6eb6b0-ec2f-4e39-9a40-37a2b2ea1ba8/resourceGroups/dvyn-dev-networking-rg/providers/Microsoft.Network/virtualNetworks/dvyn-dev-vnet-001/subnets/AzureBastionSubnet"
    public_ip_address_id = "/subscriptions/cc6eb6b0-ec2f-4e39-9a40-37a2b2ea1ba8/resourceGroups/dvyn-dev-networking-rg/providers/Microsoft.Network/publicIPAddresses/dvyn-dev-pip-bastion"
    tags                 = { Environment = "dev", Component = "bastion" }
  }
}
