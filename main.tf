terraform {
  required_version = ">= 0.13.6"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 1.26.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
  }
}
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}