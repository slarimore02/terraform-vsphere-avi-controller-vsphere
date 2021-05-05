# AVI Controller Deployment on vSphere Terraform module
This Terraform module creates and configures an AVI (NSX Advanced Load-Balancer) Controller on vSphere

## Module Functions
The module is meant to be modular and can create all or none of the prerequiste resources needed for the AVI vSphere Deployment including:
* vSphere Role for Avi (optional with create_role variable)
* vSphere virtual machines for Avi Controller(s)
* Cluster Anti-Affinity rules for HA Avi Controller Deployment

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

## vSphere Authentication
For authenticating to vSphere both the vsphere_username and vsphere_password variables will be used. The credentials must have the following permissions in vSphere:

By default this module will use the same credentials (vsphere_username and vsphere_password) for the Avi Controller to connect to vCenter and deploy resources.
To change this behavior set the "vsphere_avi_user" and "vsphere_avi_password" variables.
## Controller Image
The AVI Controller image for vSphere should be uploaded to a vSphere Content Library before running this module with the content library name and image name specified in the respective content_library and vm_template variables. 
## Host OS 
The following packages must be installed on the host operating system:
* curl 

# Usage
```hcl
terraform {
  backend "local" {
  }
}
module "avi-controller-vsphere" {
  source  = "slarimore02/avi-controller-vsphere/vsphere"
  version = "1.0.x"
  
  controller_default_password = "PASSWORD"
  avi_version                 = "20.1.5"
  controller_password         = "NEWPASSWORD"
  controller_ha               = "true"
  create_roles                = "true"
  vsphere_datacenter          = "DATACENTER"
  content_library             = "CONTENT_LIBRARY_NAME"
  vm_template                 = "controller-20.1.5-9148"
  vm_datastore                = "DATASTORE"
  name_prefix                 = "PREFIX"
  dns_servers                 = [{ addr = "8.8.4.4", type = "V4" }, { addr = "8.8.8.8", type = "V4" }]
  dns_search_domain           = "vmware.com"
  ntp_servers                 = [{ "addr": "0.us.pool.ntp.org","type": "DNS" },{ "addr": "1.us.pool.ntp.org","type": "DNS" },{ "addr": "2.us.pool.ntp.org", "type": "DNS" },{ "addr": "3.us.pool.ntp.org", "type": "DNS" }]
  se_mgmt_portgroup           = "SE_PORTGROUP"
  se_mgmt_network             = { network = "192.168.110.0/24", gateway = "192.168.110.1", type = "V4", static_pool = ["192.168.110.100", "192.168.110.200"] }
  controller_mgmt_portgroup   = "MGMT_PORTGROUP"
  compute_cluster             = "CLUSTER"
  vm_folder                   = "FOLDER"
  vsphere_user                = "USERNAME"
  vsphere_avi_user            = "USERNAME"
  vsphere_avi_password        = "PASSWORD"
  vsphere_password            = "PASSWORD"
  vsphere_server              = "VCENTER_ADDRESS"
  controller_ip               = ["192.168.110.10"]
  controller_netmask          = "24"
  controller_gateway          = "192.168.110.1"
  configure_ipam_profile      = "true"
  ipam_networks                   = [{ portgroup = "PORTGROUP", network = "100.64.220.0/24", type = "V4", static_pool = ["100.64.220.20", "100.64.220.45"] }]
  configure_dns_profile           = "true"
  dns_service_domain              = "domain.net"
  configure_dns_vs                = "true"
  dns_vs_settings                 = { auto_allocate_ip = "true", vs_ip = "", portgroup = "PORTGROUP", network = "100.64.220.0/24", type = "V4" }
}


output "controllers" {
  value = module.avi-controller-vsphere.controllers
}
```

## VMware User Role for Avi
Optionally the vSphere Roles detailed in https://avinetworks.com/docs/latest/vmware-user-role can be created and associated with an vSphere Account. 
To enable this feature set the create_roles variable to "true". If set to "false" these roles should have already been created and assigned to the account that Avi will use.
 
When the create_roles variable is set to "true" the following command should be ran to remove the avi_root role and permissions before running a terraform destroy. The avi_root role can be cleaned up manually by navigating to the Administration > Access Control > Roles section and selecting delete for the avi_root role. This is due to a bug in the vSphere provider - https://github.com/hashicorp/terraform-provider-vsphere/issues/1400
```bash  
terraform state rm vsphere_entity_permissions.avi_root vsphere_role.avi_root
```
## GSLB Deployment Example
```hcl
terraform {
  backend "local" {
  }
}
module "avi_controller_west" {
  source  = "slarimore02/avi-controller-vsphere/vsphere"
  version = "1.0.x"
  
  controller_default_password = "PASSWORD"
  avi_version                 = "20.1.5"
  controller_password         = "NEWPASSWORD"
  controller_ha               = "true"
  create_roles                = "true"
  vsphere_datacenter          = "DATACENTER"
  content_library             = "CONTENT_LIBRARY_NAME"
  vm_template                 = "controller-20.1.5-9148"
  vm_datastore                = "DATASTORE"
  name_prefix                 = "PREFIX"
  dns_servers                 = [{ addr = "8.8.4.4", type = "V4" }, { addr = "8.8.8.8", type = "V4" }]
  dns_search_domain           = "vmware.com"
  ntp_servers                 = [{ "addr": "0.us.pool.ntp.org","type": "DNS" },{ "addr": "1.us.pool.ntp.org","type": "DNS" },{ "addr": "2.us.pool.ntp.org", "type": "DNS" },{ "addr": "3.us.pool.ntp.org", "type": "DNS" }]
  se_mgmt_portgroup           = "SE_PORTGROUP"
  se_mgmt_network             = { network = "192.168.110.0/24", gateway = "192.168.110.1", type = "V4", static_pool = ["192.168.110.100", "192.168.110.200"] }
  controller_mgmt_portgroup   = "MGMT_PORTGROUP"
  compute_cluster             = "CLUSTER"
  vm_folder                   = "FOLDER"
  vsphere_user                = "USERNAME"
  vsphere_avi_user            = "USERNAME"
  vsphere_avi_password        = "PASSWORD"
  vsphere_password            = "PASSWORD"
  vsphere_server              = "VCENTER_ADDRESS"
  controller_ip               = ["192.168.110.10"]
  controller_netmask          = "24"
  controller_gateway          = "192.168.110.1"
  configure_ipam_profile      = "true"
  ipam_networks                   = [{ portgroup = "PORTGROUP", network = "100.64.220.0/24", type = "V4", static_pool = ["100.64.220.20", "100.64.220.45"] }]
  configure_dns_profile           = "true"
  dns_service_domain              = "domain.net"
  configure_dns_vs                = "true"
  dns_vs_settings                 = { auto_allocate_ip = "true", vs_ip = "", portgroup = "PORTGROUP", network = "100.64.220.0/24", type = "V4" }
  configure_gslb                  = "true"
  gslb_site_name                  = "West1"
  gslb_domains                    = ["gslb.avidemo.net"]
  configure_gslb_additional_sites = "true"
  additional_gslb_sites           = [{name = "East1", ip_address = module.avi_controller_east.gslb_ip , dns_vs_name = "DNS-VS"}]
}

module "avi_controller_east" {
  source  = "slarimore02/avi-controller-vsphere/vsphere"
  version = "1.0.x"
  
  controller_default_password = "PASSWORD"
  avi_version                 = "20.1.5"
  controller_password         = "NEWPASSWORD"
  controller_ha               = "true"
  create_roles                = "true"
  vsphere_datacenter          = "DATACENTER"
  content_library             = "CONTENT_LIBRARY_NAME"
  vm_template                 = "controller-20.1.5-9148"
  vm_datastore                = "DATASTORE"
  name_prefix                 = "PREFIX"
  dns_servers                 = [{ addr = "8.8.4.4", type = "V4" }, { addr = "8.8.8.8", type = "V4" }]
  dns_search_domain           = "vmware.com"
  ntp_servers                 = [{ "addr": "0.us.pool.ntp.org","type": "DNS" },{ "addr": "1.us.pool.ntp.org","type": "DNS" },{ "addr": "2.us.pool.ntp.org", "type": "DNS" },{ "addr": "3.us.pool.ntp.org", "type": "DNS" }]
  se_mgmt_portgroup           = "SE_PORTGROUP"
  se_mgmt_network             = { network = "192.168.120.0/24", gateway = "192.168.120.1", type = "V4", static_pool = ["192.168.120.100", "192.168.120.200"] }
  controller_mgmt_portgroup   = "MGMT_PORTGROUP"
  compute_cluster             = "CLUSTER"
  vm_folder                   = "FOLDER"
  vsphere_user                = "USERNAME"
  vsphere_avi_user            = "USERNAME"
  vsphere_avi_password        = "PASSWORD"
  vsphere_password            = "PASSWORD"
  vsphere_server              = "VCENTER_ADDRESS"
  controller_ip               = ["192.168.120.10"]
  controller_netmask          = "24"
  controller_gateway          = "192.168.120.1"
  configure_ipam_profile      = "true"
  ipam_networks                   = [{ portgroup = "PORTGROUP", network = "100.64.230.0/24", type = "V4", static_pool = ["100.64.230.20", "100.64.230.45"] }]
  configure_dns_profile           = "true"
  dns_service_domain              = "domain.net"
  configure_dns_vs                = "true"
  dns_vs_settings                 = { auto_allocate_ip = "true", vs_ip = "", portgroup = "PORTGROUP", network = "100.64.230.0/24", type = "V4" }
}


output "controllers_west" {
  value = module.avi_controller_west.controllers
}
output "gslb_leader_ip" {
  value = module.avi_controller_west.gslb_ip
}
output "controllers_east" { 
  value = module.avi_controller_east.controllers
}
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
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.6 |
| null | 3.0.0 |
| vsphere | ~> 1.26.0 |

## Providers

| Name | Version |
|------|---------|
| null | 3.0.0 |
| vsphere | ~> 1.26.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_gslb\_sites | The Names and IP addresses of the GSLB Sites that will be configured. | `list(object({ name = string, ip_address = string, dns_vs_name = string }))` | <pre>[<br>  {<br>    "dns_vs_name": "",<br>    "ip_address": "",<br>    "name": ""<br>  }<br>]</pre> | no |
| avi\_version | The version of Avi that will be deployed | `string` | n/a | yes |
| boot\_disk\_size | The boot disk size for the Avi controller | `number` | `128` | no |
| compute\_cluster | The name of the vSphere cluster that the Avi Controllers will be deployed to | `string` | `null` | no |
| configure\_dns\_profile | Configure Avi DNS Profile for DNS Record Creation for Virtual Services. If set to true the dns\_service\_domain variable must also be set | `bool` | `"false"` | no |
| configure\_dns\_vs | Create DNS Virtual Service. The configure\_dns\_profile and dns\_vs\_settings variables must also be set for the DNS VS to be created successfully. | `bool` | `"false"` | no |
| configure\_gslb | Configure GSLB. The gslb\_site\_name, gslb\_domains, and configure\_dns\_vs variables must also be set. Optionally the additional\_gslb\_sites variable can be used to add active GSLB sites | `bool` | `"false"` | no |
| configure\_gslb\_additional\_sites | Configure Additional GSLB Sites. The additional\_gslb\_sites, gslb\_site\_name, gslb\_domains, and configure\_dns\_vs variables must also be set. Optionally the additional\_gslb\_sites variable can be used to add active GSLB sites | `bool` | `"false"` | no |
| configure\_ipam\_profile | Configure Avi IPAM Profile for Virtual Service Address Allocation. If set to true the virtualservice\_network variable must also be set | `bool` | `"false"` | no |
| configure\_se\_mgmt\_network | When true the se\_mgmt\_network\_address variable must be configured. If set to false, DHCP is enabled on the vSphere portgroup that the Avi Service Engines will use for management. | `bool` | `"true"` | no |
| content\_library | The name of the Content Library that has the Avi Controller Image | `string` | n/a | yes |
| controller\_default\_password | This is the default password for the Avi controller image and can be found in the image download page. | `string` | n/a | yes |
| controller\_gateway | The IP Address of the gateway for the controller mgmt network | `string` | n/a | yes |
| controller\_ha | If true a HA controller cluster is deployed and configured | `bool` | `"false"` | no |
| controller\_ip | A list of IP Addresses that will be assigned to the Avi Controller(s). For a full HA deployment the list should contain 4 IP addresses. The first 3 addresses will be used for the individual controllers and the 4th IP address listed will be used as the Cluster IP | `list(string)` | n/a | yes |
| controller\_mgmt\_portgroup | The vSphere portgroup name that the Avi Controller will use for management | `string` | n/a | yes |
| controller\_netmask | The subnet mask of the controller mgmt network | `string` | n/a | yes |
| controller\_password | The password that will be used authenticating with the Avi Controller. This password be a minimum of 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters | `string` | n/a | yes |
| controller\_size | This value determines the number of vCPUs and memory allocated for the Avi Controller. Possible values are small, medium, or large. | `string` | `"small"` | no |
| create\_roles | This variable controls the creation of Avi specific vSphere Roles for the Avi Controller to use. When set to false these roles should already be created and assigned to the vSphere account used by the Avi Controller. | `bool` | `"false"` | no |
| dns\_search\_domain | The optional DNS search domain that will be used by the controller | `string` | `null` | no |
| dns\_servers | The optional DNS servers that will be used for local DNS resolution by the controller. The server should be a valid IP address (v4 or v6) and valid options for type are V4 or V6. Example: [{ addr = "8.8.4.4", type = "V4"}, { addr = "8.8.8.8", type = "V4"}] | `list(object({ addr = string, type = string }))` | `null` | no |
| dns\_service\_domain | The DNS Domain that will be available for Virtual Services. Avi will be the Authorative Nameserver for this domain and NS records may need to be created pointing to the Avi Service Engine addresses. An example is demo.avi.com | `string` | `null` | no |
| dns\_vs\_settings | The DNS Virtual Service settings. With the auto\_allocate\_ip option is set to "true" the VS IP address will be allocated via an IPAM profile. Valid options for type are V4 or V6. Example:{ auto\_allocate\_ip = "true", vs\_ip = "", portgroup = "dns-portgroup", network = "192.168.20.0/24", type = "V4" } | `object({ auto_allocate_ip = bool, vs_ip = string, portgroup = string, network = string, type = string, vs_ip = string })` | `null` | no |
| email\_config | The Email settings that will be used for sending password reset information or for trigged alerts. The default setting will send emails directly from the Avi Controller | `object({ smtp_type = string, from_email = string, mail_server_name = string, mail_server_port = string, auth_username = string, auth_password = string })` | <pre>{<br>  "auth_password": "",<br>  "auth_username": "",<br>  "from_email": "admin@avicontroller.net",<br>  "mail_server_name": "localhost",<br>  "mail_server_port": "25",<br>  "smtp_type": "SMTP_LOCAL_HOST"<br>}</pre> | no |
| gslb\_domains | A list of GSLB domains that will be configured | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| gslb\_site\_name | The name of the GSLB site the deployed Controller(s) will be a member of. | `string` | `""` | no |
| ipam\_networks | This variable configures the IPAM network(s). Example: { portgroup = "vs-portgroup", network = "192.168.20.0/24" , gateway = "192.168.20.1", type = "V4", static\_pool = ["192.168.20.10","192.168.20.30"]} | `list(object({ portgroup = string, network = string, type = string, static_pool = list(string) }))` | <pre>[<br>  {<br>    "network": "",<br>    "portgroup": "",<br>    "static_pool": [<br>      ""<br>    ],<br>    "type": ""<br>  }<br>]</pre> | no |
| name\_prefix | This prefix is appended to the names of the Controller and SEs | `string` | n/a | yes |
| ntp\_servers | The NTP Servers that the Avi Controllers will use. The server should be a valid IP address (v4 or v6) or a DNS name. Valid options for type are V4, DNS, or V6 | `list(object({ addr = string, type = string }))` | <pre>[<br>  {<br>    "addr": "0.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "1.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "2.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "3.us.pool.ntp.org",<br>    "type": "DNS"<br>  }<br>]</pre> | no |
| se\_ha\_mode | The HA mode of the Service Engine Group. Possible values active/active, n+m, or active/standby | `string` | `"active/active"` | no |
| se\_mgmt\_network | This variable configures the SE management network. Example: { network = "192.168.10.0/24" , gateway = "192.168.10.1", type = "V4", static\_pool = ["192.168.10.10","192.168.10.30"]} | `object({ network = string, gateway = string, type = string, static_pool = list(string) })` | <pre>{<br>  "gateway": "",<br>  "network": "",<br>  "static_pool": [<br>    ""<br>  ],<br>  "type": ""<br>}</pre> | no |
| se\_mgmt\_portgroup | The vSphere portgroup that the Avi Service Engines will use for management | `string` | `null` | no |
| se\_size | The CPU, Memory, Disk Size of the Service Engines. The default is 1 vCPU, 2 GB RAM, and a 15 GB Disk per Service Engine. Syntax ["cpu\_cores", "memory\_in\_GB", "disk\_size\_in\_GB"] | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "15"<br>]</pre> | no |
| vm\_datastore | The vSphere Datastore that will back the Avi Controller VMs | `string` | n/a | yes |
| vm\_folder | The folder that the Avi Controller(s) will be placed in. This will be the full path and name of the folder that will be created | `string` | n/a | yes |
| vm\_resource\_pool | The Resource Pool that the Avi Controller(s) will be deployed to | `string` | `""` | no |
| vm\_template | The name of the Avi Controller Image that is hosted in a Content Library | `string` | n/a | yes |
| vsphere\_avi\_password | The password for the user account that will be used for accessing vCenter from the Avi Controller(s) | `string` | `null` | no |
| vsphere\_avi\_user | The user account that will be used for accessing vCenter from the Avi Controller(s) | `string` | `null` | no |
| vsphere\_datacenter | The vSphere Datacenter that the Avi Controller(s) will be deployed | `string` | n/a | yes |
| vsphere\_password | The password for the user account that will be used for creating vSphere resources | `string` | n/a | yes |
| vsphere\_server | The IP Address or FQDN of the VMware vCenter server | `string` | n/a | yes |
| vsphere\_user | The user account that will be used to create the Avi Controller(s) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| controllers | AVI Controller Information |
| gslb\_ip | The IP Address of AVI Controller Information |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->