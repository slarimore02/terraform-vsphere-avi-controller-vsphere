output "controllers" {
  description = "The AVI Controller(s) Information"
  value = ([for s in vsphere_virtual_machine.avi_controller : merge(
    { "name" = s.name },
    { "private_ip_address" = s.vapp.properties.mgmt-ip }
    )
    ]
  )
}
