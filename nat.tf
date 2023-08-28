locals {
  nats = { for n in var.nats : n.name => n }
}

resource "google_compute_router_nat" "nat" {
  for_each = local.nats

  name    = each.value.name
  project = google_compute_router.router[0].project
  router  = google_compute_router.router[0].name
  region  = google_compute_router.router[0].region
  enable_dynamic_port_allocation = false
  enable_endpoint_independent_mapping = false
  nat_ip_allocate_option             = try(each.value.nat_ip_allocate_option, length(try(each.value.nat_ips, [])) > 0 ? "MANUAL_ONLY" : "AUTO_ONLY")
  source_subnetwork_ip_ranges_to_nat = try(each.value.source_subnetwork_ip_ranges_to_nat, "ALL_SUBNETWORKS_ALL_IP_RANGES")

  nat_ips = try(each.value.nat_ips, null)

  min_ports_per_vm = try(each.value.min_ports_per_vm, null)

  udp_idle_timeout_sec             = try(each.value.idle_timeout_sec, 30)
  icmp_idle_timeout_sec            = try(each.value.icmp_idle_timeout_sec, 30)
  tcp_established_idle_timeout_sec = try(each.value.tcp_established_idle_timeout_sec, 1200)
  tcp_transitory_idle_timeout_sec  = try(each.value.tcp_transitory_idle_timeout_sec, 30)

  log_config {
    enable = true
    filter = try(each.value.log_config.filter, "ALL")
  }

  dynamic "subnetwork" {
    for_each = try(each.value.subnetworks, [])
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = try(subnetwork.value.secondary_ip_range_names, [])
    }
  }

  depends_on = [var.module_depends_on]
}
