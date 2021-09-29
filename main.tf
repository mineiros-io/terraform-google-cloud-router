resource "google_compute_router" "router" {
  count = var.module_enabled ? 1 : 0

  name    = var.name
  region  = var.region
  project = var.project
  network = var.network

  dynamic "bgp" {
    for_each = var.bgp != null ? [1] : []
    content {
      asn = var.bgp.asn

      # advertise_mode is intentionally set to CUSTOM to not allow "DEFAULT".
      # This forces the config to explicitly state what subnets and ip ranges
      # to advertise. To advertise the same range as DEFAULT, set
      # `advertise_groups = ["ALL_SUBNETS"]`.
      advertise_mode    = "CUSTOM"
      advertised_groups = try(var.bgp.advertised_groups, null)

      dynamic "advertised_ip_ranges" {
        for_each = try(var.bgp.advertised_ip_ranges, [])
        content {
          range       = advertised_ip_ranges.value.range
          description = try(advertised_ip_ranges.value.description, null)
        }
      }
    }
  }

  depends_on = [var.module_depends_on]
}
