variable "location" {
  description = "The location/region where resource will be created. The full list of Azure regions can be found at https://azure.microsoft.com/regions"
  type = string
}

variable "prefix" {
  description = "VM name"
  type = string
}

variable "address_space" {
  description = "The address space that is used by a Virtual Network."
  type = string
}

variable "internal_subnet" {
  description = "Address prefix to be used for network frontend subnet"
  type = string
}

variable "vm_count" {
  description = "Number of WinD machines to deploy"
  default     = 2
}

variable "vm_size" {
  description = "VM name"
  type = string
}

variable "vm_user" {
  description = "VM name"
  type = string
}

variable "vm_password" {
  description = "VM name"
  type = string
}

variable "vm_timezone" {
  description = "https://jackstromberg.com/2017/01/list-of-time-zones-consumed-by-azure/"
  type = string
}

variable "azure_publisher" {
  description = "VM name"
  type = string
}

variable "azure_offer" {
  description = "VM name"
  type = string
}

variable "azure_sku" {
  description = "VM name"
  type = string
}

variable "azure_version" {
  description = "VM name"
  type = string
}

variable "internet_acl" {
  description = "List of IPs and subnets that can access VMs from internet"
  type = list
}
