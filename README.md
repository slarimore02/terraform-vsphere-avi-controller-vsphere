# AVI Controller Deployment on vSphere Terraform module
This Terraform module creates and configures an AVI (NSX Advanced Load-Balancer) Controller on vSphere

## Module Functions
The module is meant to be modular and can create all or none of the prerequiste resources needed for the AVI vSphere Deployment including:
* Portgroup for the Controller (optional with create_networking variable)
* vSphere Role for Avi (optional with create_role variable)
* vSphere virtual machines for Avi Controller(s)

During the creation of the Controller instance the following initialization steps are performed:
* Change default password to user specified password
* Copy Ansible playbook to controller using the assigned IP Address
* Run Ansible playbook to configure initial settings and vSphere Full Access Cloud 

Optionally the following Avi configurations can be created:
* Avi IPAM Profile (configure_ipam_profile variable)
* Avi DNS Profile (configure_dns_profile variable)
* DNS Virtual Service (configure_dns_vs variable)

# Environment Requirements

## vSphere
The following are vSphere prerequisites for running this module:
* vSphere Account with permissions to create VMs and any other vSphere resources created by this module
* Port Groups indentified for Management

## Google Provider
For authenticating to vSphere both the vsphere_username and vsphere_password variables will be used
## Controller Image
The AVI Controller image for vSphere should be uploaded to a vSphere Content Library before running this module with the content library name and image name specified in the respective content_library and vm_template variables. 
## Host OS 
The following packages must be installed on the host operating system:
* curl 

# Usage
```hcl

```
## GSLB Deployment Example
```hcl

```
## Controller Sizing
The controller_size variable can be used to determine the vCPU and Memory resources allocated to the Avi Controller. There are 3 available sizes for the Controller as documented below:

| Size | vCPU Cores | Memory (GB)|
|------|-----------|--------|
| small | 8 | 24 |
| medium | 16 | 32 |
| large | 24 | 48 |

Additional resources on sizing the Avi Controller:

https://avinetworks.com/docs/latest/avi-controller-sizing/
https://avinetworks.com/docs/latest/system-limits/


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
