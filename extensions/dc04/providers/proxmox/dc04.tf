variable "config_dc04_ext" {
  type = map(object({
    name               = string
    desc               = string
    cores              = number
    memory             = number
    clone              = string
    dns                = string
    ip                 = string
    gateway            = string
  }))

  default = {
    "dc04" = {
       name               = "GOAD-DC04"
       desc               = "DC04 - windows server 2025 - 192.168.10.13"
       cores              = 2
       memory             = 3096
       clone              = "WinServer2025_x64"
       dns                = "192.168.10.1"
       ip                 = "192.168.10.13/24"
       gateway            = "192.168.10.1"
    }
  }
}

locals {
  vm_config = merge(config_dc04_ext, var.vm_config)
}
