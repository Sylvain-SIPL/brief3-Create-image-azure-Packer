

variable "resource_group_name" {
   description = "Name of the resource group in which the resources will be created"
   default     = "PackergroupSylvain"
}


variable "location" {
   default = "north europe"
   description = "Location where resources will be created"
}

variable "packer_resource_group_name" {
   description = "Name of the resource group in which the Packer image will be created"
   default     = "debiangroupSylvain"
}


variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "Packerdebian2"
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "admindebian"
}
