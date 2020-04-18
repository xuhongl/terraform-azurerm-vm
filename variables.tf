variable "resourceGroup" {
  description = "The Azure resource group where all resources in this example should be created"
  default    = "TDrockhopper1"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default    = "eastus"
}

variable "tags" {
  type = map(string)
  default = {environment = "Terraform Demo"}
}

variable "vnetName" {
  default    = "myVnet"
}

variable "vnetAddSpace" {
  default    = "10.0.0.0/16"
}

variable "address_prefix" {
  default    = "10.0.2.0/24"
}

variable "azurerm_public_ip_name" {
  default    = "myPublicIP"
}

variable "azurerm_public_ip_allocation_method" {
  default    = "Dynamic"
}

variable "azurerm_network_security_group_name" {
  default    = "myNetworkSecurityGroup"
}

variable "azurerm_network_interface_name" {
  default    = "myNIC"
}

variable "vm_name" {
  default    = "myVM"
}

variable "vm_size" {
  default    = "Standard_DS1_v2"
}

variable "ad_group_suffix" {
  description = "AD Group Suffix" 
  default    = "xxxxuhong"
}
