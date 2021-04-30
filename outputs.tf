output "controllers" {
  description = "The AVI Controller(s) Information"
  value = ([for item in vsphere_virtual_machine.avi_controller : merge(
    { "name" = item.name },
    { "private_ip_address" = item.default_ip_address }
    )
    ]
  )
}