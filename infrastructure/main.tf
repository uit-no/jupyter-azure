
resource "azurerm_storage_account" "spokestor" {
  name                     = var.storageaccountname
  location                 = data.azurerm_resource_group.spokerg.location
  resource_group_name      = data.azurerm_resource_group.spokerg.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
}

resource "azurerm_private_dns_zone" "spoke" {
  name                = "spoketest.internal"
  resource_group_name = data.azurerm_resource_group.spokerg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  name                  = "spoke"
  resource_group_name   = data.azurerm_resource_group.spokerg.name
  private_dns_zone_name = azurerm_private_dns_zone.spoke.name
  virtual_network_id    = data.azurerm_virtual_network.spokenet.id
  registration_enabled  = true
}


resource "azurerm_network_interface" "nic" {
  name                = "nic${count.index}"
  count               = var.numhosts
  location            = data.azurerm_resource_group.spokenetrg.location
  resource_group_name = data.azurerm_resource_group.spokerg.name

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = data.azurerm_subnet.spokefrontnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                          = "${var.hostname}${format("%02d", count.index)}"
  count                         = var.numhosts
  location                      = data.azurerm_resource_group.spokerg.location
  resource_group_name           = data.azurerm_resource_group.spokerg.name
  vm_size                       = var.vm_size
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  #   storage_image_reference {
  #     id = data.azurerm_image.custom.id
  #   }

  storage_os_disk {
    name              = "osdisk${count.index}"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.spokestor.primary_blob_endpoint
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("~/.ssh/roy.key.pub")
    }
  }
  os_profile {
    computer_name  = "${var.hostname}${format("%02d", count.index)}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  # os_profile_windows_config {}

  # doesn't work, use custom_data instead
  # provisioner "file" {
  #   source      = "hostkeys/"
  #   destination = "/etc/ssh"
  #   connection {
  #     type = "ssh"
  #     user = "sysadm"
  #     host = self.network_interface_ids[0]
  #     bastion_host = 
  #   }
  # }
}



output "id" {
  value = data.azurerm_resource_group.spokerg.id
}
