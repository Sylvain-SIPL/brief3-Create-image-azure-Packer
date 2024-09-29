provider "azurerm" {
  features {}
}


#create group

resource "azurerm_resource_group" "debianstack" {
  name     = var.resource_group_name
  location = var.location
}


# virtual network definition 
resource "azurerm_virtual_network" "debianstack" {
  name                = "debiangroup-vnet"
  address_space       = ["10.0.0.0/26"]
  location            = var.location
  resource_group_name = azurerm_resource_group.debianstack.name
}


# subnet definition
resource "azurerm_subnet" "debianstack" {
  name                 = "debiangroup-subnet"
  resource_group_name  = azurerm_resource_group.debianstack.name
  virtual_network_name = azurerm_virtual_network.debianstack.name
  address_prefixes     = ["10.0.0.0/28"]
}

# public IP
resource "azurerm_public_ip" "debianstack"{
  name                = "debian-publicip"
  location            = var.location
  resource_group_name = azurerm_resource_group.debianstack.name
  allocation_method   = "Static"
}

# network interface définition 
resource "azurerm_network_interface" "debianstack" {
  name                = "debiangroup-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.debianstack.name

  ip_configuration {
    name                          = "debian-ipconfig"
    subnet_id                     = azurerm_subnet.debianstack.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.debianstack.id
  }
}




# locate existing image

data "azurerm_image" "main" {
  name                = var.packer_image_name
  resource_group_name = var.packer_resource_group_name
}

#create vm with packer file
resource "azurerm_linux_virtual_machine" "debianstack" {
  name                   = "debian-vm"
  location               = var.location
  resource_group_name    = azurerm_resource_group.debianstack.name
  size                   = "Standard_B1ls"
  admin_username         = "admindebian"
  disable_password_authentication = true
  network_interface_ids  = [azurerm_network_interface.debianstack.id]
  source_image_id = data.azurerm_image.main.id

  

# parameter access with ssh key 

  admin_ssh_key{
    username   = var.admin_user
    public_key = file("C:/Users/Apprenant/.ssh/id_rsa.pub")
  }
  

# create disk 

  os_disk {
    name                 = "debian-vm"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}


# network security group 

# association nsg and ni
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.debianstack.id
  network_security_group_id = azurerm_network_security_group.debianstack.id
}

resource "azurerm_network_security_group" "debianstack"{
  name                = "debian-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.debianstack.name


# security rule SSH et HTTP
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
  
  
  security_rule {     
  
  name                       = "HTTP"     
  priority                   = 1010     
  direction                  = "Inbound"     
  access                     = "Allow"     
  protocol                   = "Tcp"     
  source_port_range          = "*"     
  destination_port_range     = "80"     
  source_address_prefix      = "*"     
  destination_address_prefix = "*"   
  
  }
}






