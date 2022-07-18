
resource "azurerm_storage_account" "spokestor" {
  name                     = var.storageaccountname
  location                 = data.azurerm_resource_group.spokerg.location
  resource_group_name      = data.azurerm_resource_group.spokerg.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
}

# resource "azurerm_private_dns_zone" "spoke" {
#   name                = "spoketest.internal"
#   resource_group_name = data.azurerm_resource_group.spokerg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
#   name                  = "spoke"
#   resource_group_name   = data.azurerm_resource_group.spokerg.name
#   private_dns_zone_name = azurerm_private_dns_zone.spoke.name
#   virtual_network_id    = data.azurerm_virtual_network.spokenet.id
#   registration_enabled  = true
# }


resource "azurerm_network_interface" "nic" {
  name                = "${var.hostname}nic${count.index}"
  count               = var.numhosts
  location            = data.azurerm_resource_group.spokenetrg.location
  resource_group_name = data.azurerm_resource_group.spokerg.name

  ip_configuration {
    name                          = "${var.hostname}ipconfig${count.index}"
    subnet_id                     = data.azurerm_subnet.spokefrontnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# resource "azurerm_marketplace_agreement" "rockylinux" {
#   publisher = var.image_publisher
#   offer     = var.image_offer
#   plan      = "latest"
# }

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.hostname}${format("%02d", count.index)}"
  count                           = var.numhosts
  location                        = data.azurerm_resource_group.spokerg.location
  resource_group_name             = data.azurerm_resource_group.spokerg.name
  size                            = var.vm_size
  network_interface_ids           = [azurerm_network_interface.nic[count.index].id]
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/roy.key.pub")
  }

  plan {
    publisher = var.image_publisher
    product   = var.image_offer
    name      = var.image_sku
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  #   storage_image_reference {
  #     id = data.azurerm_image.custom.id
  #   }

  os_disk {
    name                 = "${var.hostname}sysdisk${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb          = 16
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.spokestor.primary_blob_endpoint
  }
}



output "id" {
  value = data.azurerm_resource_group.spokerg.id
}

output "ips" {
  value = azurerm_network_interface.nic[*].private_ip_address
}
