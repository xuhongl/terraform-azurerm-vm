provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}

    subscription_id = "99a1241a-f743-4202-a85f-dddf3f2448b6"
    client_id       = "f339a20c-aed0-47a1-b379-6bb6a3dceef9"
    client_secret   = "4ab84a29-7a6e-404f-acd8-ad621b5ef9b1"
    tenant_id       = "9be65afb-169d-45b7-bcc2-987e74362a97"
}

resource "azurerm_resource_group" "myterraformgroup" {
    name     = var.resourceGroup
    location = var.location
    tags = var.tags
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = var.vnetName
    address_space       = ["${var.vnetAddSpace}"]
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    tags = var.tags
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = var.address_prefix
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = var.azurerm_public_ip_name
    location                     = azurerm_resource_group.myterraformgroup.location
    resource_group_name          = azurerm_resource_group.myterraformgroup.name
    allocation_method            = var.azurerm_public_ip_allocation_method
    tags = var.tags

}

resource "azurerm_network_security_group" "myterraformnsg" {
    name                = var.azurerm_network_security_group_name
    location            = azurerm_resource_group.myterraformgroup.location
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = var.tags


}

resource "azurerm_network_interface" "myterraformnic" {
    name                        = "myNIC"
    location                    = "eastus"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.myterraformsubnet.id}"
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = "${azurerm_public_ip.myterraformpublicip.id}"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.myterraformgroup.name
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
    tags = var.tags
}

resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = var.location
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    admin_password = "Password1234!"
    disable_password_authentication = false    

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = var.tags

}