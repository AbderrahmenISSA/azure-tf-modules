variable "APP_NAME" {
  description = "Application Name"
}

variable "ENV_PREFIX" {
  description = "Environment"
}


variable "RG_NAME" {
  description = "Ressource group name"
}

variable "RG_LOCATION" {
  description = "Ressource group location"
}

variable "SUBNET_ID" {
  description = "Subnet of the VM"
}

variable "VM_SIZE" {
  description = "Size of the VM"
}

variable "VM_OS_DISK" {
  description = "Operating System of the VM"
}

variable "SSH_USER" {
  description = "SSH User"
}

variable "PUBLIC_KEY" {
  description = "Public Key"
}

variable "ALLOW_8080" {
  description = "Allow 8080 security rule"
}

variable "ALLOW_80" {
  description = "Allow 80 security rule"
}

variable "ALLOW_22" {
  description = "Allow 22 security rule"
}