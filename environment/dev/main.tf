module "vnet" {
  source              = "../../modules/azurerm_vnet"
  vnet_name           = "V-Net"
  location            = "centralindia"
  resource_group_name = "rg-dev-india"
  address_space       = ["10.0.0.0/16"]
}

module "subnet" {
    depends_on = [ module.vnet ]
  source               = "../../modules/azurerm_subnet"
  subnet_name          = "frontend-subnet"
  resource_group_name  = "rg-dev-india"
  virtual_network_name = "V-Net"
  address_prefixes     = ["10.0.0.0/24"]
}

module "subnet1" {
    depends_on = [ module.vnet ]
  source               = "../../modules/azurerm_subnet"
  subnet_name          = "backend-subnet"
  resource_group_name  = "rg-dev-india"
  virtual_network_name = "V-Net"
  address_prefixes     = ["10.0.1.0/24"]
}

module "pip" {
  source              = "../../modules/azurerm_public_ip"
  pip_name            = "frontend-pip"
  location            = "centralindia"
  resource_group_name = "rg-dev-india"
}

module "pip1" {
  source              = "../../modules/azurerm_public_ip"
  pip_name            = "backend-pip"
  location            = "centralindia"
  resource_group_name = "rg-dev-india"
}

module "nsg" {
  source                  = "../../modules/azurerm_nsg"
  nsg_name                = "frontend-network-security-group"
  location                = "centralindia"
  resource_group_name     = "rg-dev-india"
  destination_port_ranges = ["22", "80"]
}

module "nsg1" {
  source                  = "../../modules/azurerm_nsg"
  nsg_name                = "backend-network-security-group"
  location                = "centralindia"
  resource_group_name     = "rg-dev-india"
  destination_port_ranges = ["22", "8000"]
}

module "nic" {
    depends_on = [ module.subnet ]
  source                = "../../modules/azurerm_nic"
  nic_name              = "frontend-nic"
  location              = "centralindia"
  resource_group_name   = "rg-dev-india"
  ip_configuration_name = "configuration1"
  subnet_name           = "frontend-subnet"
  pip_name              = "frontend-pip"
  virtual_network_name  = "V-Net"
}

module "nic1" {
    depends_on = [ module.subnet1 ]
  source                = "../../modules/azurerm_nic"
  nic_name              = "backend-nic"
  location              = "centralindia"
  resource_group_name   = "rg-dev-india"
  ip_configuration_name = "configuration2"
  subnet_name           = "backend-subnet"
  pip_name              = "backend-pip"
  virtual_network_name  = "V-Net"
}

module "vm" {
    depends_on = [ module.nic ]
  source              = "../../modules/azurerm_VM"
  vm_name             = "frontend-VM"
  location            = "centralindia"
  resource_group_name = "rg-dev-india"
  size                = "Standard_B2s"
  computer_name       = "ghost"
  os_disk_name        = "frontend-os-disk"
  publisher           = "Canonical"
  offer               = "0001-com-ubuntu-server-jammy"
  sku                 = "22_04-lts"
  version1            = "latest"
  key_vault_name      = "key-vault01"
  username_secret_key = "frontend-vm-username"
  pwd_secret_key      = "frontend-vm-pwd"
  nic_name            = "frontend-nic"
}

module "vm1" {
    depends_on = [ module.nic1 ]
  source              = "../../modules/azurerm_VM"
  vm_name             = "backend-VM"
  location            = "centralindia"
  resource_group_name = "rg-dev-india"
  size                = "Standard_B2s"
  computer_name       = "ghostkabapp"
  os_disk_name        = "backend-os-disk"
  publisher           = "Canonical"
  offer               = "0001-com-ubuntu-server-focal"
  sku                 = "20_04-lts"
  version1            = "latest"
  key_vault_name      = "key-vault01"
  username_secret_key = "backend-vm-username"
  pwd_secret_key      = "backend-vm-pwd"
  nic_name            = "backend-nic"
}