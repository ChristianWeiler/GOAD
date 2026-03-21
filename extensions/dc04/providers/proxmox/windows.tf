"dc04" = {
  name               = "DC04"
  desc               = "DC04 - windows server 2025 - {{ip_range}}.13"
  cores              = 2
  memory             = 3096
  clone              = "WinServer2025_x64"
  dns                = "{{ip_range}}.1"
  ip                 = "{{ip_range}}.13/24"
  gateway            = "{{ip_range}}.1"
}
