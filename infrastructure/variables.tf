# make sure config.tf contains the right setup.

variable "spokename" {
  description = "Assigned spoke name"
  default     = "p-jupytr"
}

#
# Fetch the preexisting resources (eg. networks) provided to the spoke by VDC
# These resources will not be deleted by a destroy

data "azurerm_resource_group" "spokerg" {
  name = var.spokename
}

data "azurerm_resource_group" "spokenetrg" {
  name = "${var.spokename}-network"
}

data "azurerm_virtual_network" "spokenet" {
  name                = "${data.azurerm_resource_group.spokenetrg.name}-vnet"
  resource_group_name = data.azurerm_resource_group.spokenetrg.name
}

data "azurerm_subnet" "spokefrontnet" {
  name                 = "FrontendSubnet"
  virtual_network_name = data.azurerm_virtual_network.spokenet.name
  resource_group_name  = data.azurerm_resource_group.spokenetrg.name
}

#
# Case specific stuff below
# 
variable "hostname" {
  description = "VM name referenced also in storage-related names."
  default     = "jup"
}

variable "numhosts" {
  default = 8
}

variable "storageaccountname" {
  default = "jupytvmstor"
}

variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

# variable "custom_image_resource_group_name" {
#   description = "The name of the Resource Group in which the Custom Image exists."device
#   default = "testlab201901"
# }

# variable "custom_image_name" {
#   description = "The name of the Custom Image to provision this Virtual Machine from."
#   default = "test_v5"
# }

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B4ms"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  #  default     = "OpenLogic"
  default = "erockyenterprisesoftwarefoundationinc1653071250513"
  # Procomputers sponsors rockylinux, lets sponsor them.
  # default = "procomputers"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  # default     = "CentOS"
  # default = "rocky-linux-8-latest"
  default = "rockylinux"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  # default     = "8_1"
  default = "free"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "sysadm"
}

variable "admin_password" {
  description = "administrator password (recommended to disable password auth)"
  default     = "something long and incomprehensible"
}


output "virtual_network_id" {
  value = data.azurerm_virtual_network.spokenet.id
}
