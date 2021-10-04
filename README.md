[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>][homepage]

[![Terraform Version][badge-terraform]][releases-terraform]
[![Google Provider Version][badge-tf-gcp]][releases-google-provider]
[![Join Slack][badge-slack]][slack]

# terraform-google-cloud-router

A [Terraform](https://www.terraform.io) module to create a [Google Cloud Router](https://cloud.google.com/network-connectivity/docs/router) on [Google Cloud Services (GCP)](https://cloud.google.com/).

**_This module supports Terraform version 1
and is compatible with the Terraform Google Provider version 3._**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.

- [terraform-google-cloud-router](#terraform-google-cloud-router)
  - [Module Features](#module-features)
  - [Getting Started](#getting-started)
  - [Module Argument Reference](#module-argument-reference)
    - [Top-level Arguments](#top-level-arguments)
      - [Module Configuration](#module-configuration)
      - [Main Resource Configuration](#main-resource-configuration)
      - [Extended Resource Configuration](#extended-resource-configuration)
        - [Terraform google cloud router nat](#terraform-google-cloud-router-nat)
  - [Module Attributes Reference](#module-attributes-reference)
  - [External Documentation](#external-documentation)
    - [Google Documentation:](#google-documentation)
    - [Terraform Google Provider Documentation:](#terraform-google-provider-documentation)
  - [Module Versioning](#module-versioning)
    - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
  - [About Mineiros](#about-mineiros)
  - [Reporting Issues](#reporting-issues)
  - [Contributing](#contributing)
  - [Makefile Targets](#makefile-targets)
  - [License](#license)

## Module Features

A [Terraform] module for creating a `google_compute_router` resource along with another resource  `google_compute_router_nat`. Cloud Router enables you to dynamically exchange routes between your Virtual Private Cloud (VPC) and on-premises networks by using Border Gateway Protocol (BGP).

## Getting Started

Most basic usage just setting required arguments:

```hcl
module "terraform-google-cloud-router" {
  source = "github.com/mineiros-io/terraform-google-cloud-router.git?ref=v0.1.0"

  name    = "my-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.net.id

  bgp {
    asn = 64514
  }

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Top-level Arguments

#### Module Configuration

- **`module_enabled`**: _(Optional `bool`)_

  Specifies whether resources in the module will be created.

  Default is `true`.

- **`module_depends_on`**: _(Optional `list(dependencies)`)_

  A list of dependencies. Any object can be _assigned_ to this list to define a hidden external dependency.

  Example:
  ```hcl
  module_depends_on = [
    google_compute_network.net,
    google_compute_subnetwork.subnet,
    google_compute_address.address
  ]
  ```

#### Main Resource Configuration

- **`region`**: **_(Required `string`)_**

  The region to host the VPC and all related resources in.

- **`project`**: **_(Required `string`)_**

  The ID of the project in which the resources belong.

- **`network`**: **_(Required `string`)_**

  A reference to the network to which this router belongs.

- **`name`**: _(Optional `string`)_

  Name of the resource.

  Default is `main`.

- **`bgp`**: _(Optional `object(bgp)`)_

  BGP information specific to this router.

  Each `bgp` object can have the following fields:

  Example

   ```hcl
    bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "1.2.3.4"
    }
    advertised_ip_ranges {
      range = "6.7.0.0/16"
    }
   ```

  - **`asn`**: **_(Required `string`)_**

    Local BGP Autonomous System Number `(ASN)`. Must be an RFC6996 private ASN, either `16-bit` or `32-bit`. The value will be fixed for this router resource. All VPN tunnels that link to this router will have the same local ASN.

  - **`advertise_mode`**: _(Optional `string`)_

    User-specified flag to indicate which mode to use for advertisement. Possible values are `DEFAULT` and `CUSTOM`.

    Default is `DEFAULT`.

  - **`advertised_groups`**: _(Optional `list(string)`)_

    User-specified list of prefix groups to advertise in custom mode. This field can only be populated if advertiseMode is `CUSTOM` and is advertised to all peers of the router. These groups will be advertised in addition to any specified prefixes. Leave this field blank to advertise no custom groups. This enum field has the one valid value: `ALL_SUBNETS`.

    Default is `[]`.

  - **`advertised_ip_ranges`** _(Optional `list(advertised_ip_range)`)

    User-specified list of individual IP ranges to advertise in custom mode. This field can only be populated if advertiseMode is `CUSTOM` and is advertised to all peers of the router. These IP ranges will be advertised in addition to any specified groups. Leave this field blank to advertise no custom IP ranges.

    Default is `[]`

    Each `advertised_ip_range` object can have the following fields:

    - **`range`**: **_(Required `string`)_**

      The IP range to advertise. The value must be a CIDR-formatted string.

    - **`description`**: _(Optional `string`)_

      User-specified description for the IP range.

#### Extended Resource Configuration

##### Terraform google cloud router nat

- **`nats`**: _(Optional `list(nat)`)_

  NATs to deploy on this router.

  Default is `[]`.

  Each `nat` object can have the following fields:

  Example

   ```hcl
    nat {
      name   = "my-router-nat"
      router = google_compute_router.router.name
      region = google_compute_router.router.region

      nat_ip_allocate_option = "MANUAL_ONLY"
      nat_ips                = google_compute_address.address.*.self_link

      source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
      subnetwork {
        name                    = google_compute_subnetwork.subnet.id
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
      }
    }
   ```

  - **`name`**: **_(Required `string`)_**

    Name of the NAT.

  - **`nat_ip_allocate_option`**: _(Optional `string`)_

    How external IPs should be allocated for this NAT. Defaults to `MANUAL_ONLY` if nat_ips are set, else `AUTO_ONLY`.

    Default is `AUTO_ONLY`.

  - **`source_subnetwork_ip_ranges_to_nat`**: _(Optional `string`)_

    How NAT should be configured per Subnetwork.

    Default is `ALL_SUBNETWORKS_ALL_IP_RANGES`.

  - **`nat_ips`**: _(Optional `list(number)`)_

    Self-links of NAT IPs. Only valid if `natIpAllocateOption` is set to MANUAL_ONLY.

  - **`min_ports_per_vm`**: _(Optional `number`)_

    Minimum number of ports allocated to a VM from this NAT.

  - **`udp_idle_timeout_sec`**: _(Optional `number`)_

    Timeout (in seconds) for UDP connections. Defaults to 30s if not set.

    Default is `30`.

  - **`icmp_idle_timeout_sec`**: _(Optional `number`)_

    Timeout (in seconds) for ICMP connections. Defaults to 30s if not set.

    Default is `30`.

  - **`tcp_established_idle_timeout_sec`**: _(Optional `number`)_

    Timeout (in seconds) for TCP established connections. Defaults to 1200s if not set.

    Default is `1200`.

  - **`tcp_transitory_idle_timeout_sec`**: _(Optional `number`)_

    Timeout (in seconds) for TCP transitory connections. Defaults to 30s if not set.

    Default is `30`.

  - **`log_config`**: _(Optional `object`)_

    Configuration for logging on NAT.

    Default is `[]`.

    Each `log_config` object can have the following fields:

    - **`enabled`**: **_(Required `bool`)_**

      Indicates whether or not to export logs.

      Default is `true`.

    - **`filter`**: **_(Required `string`)_**

      Specifies the desired filtering of logs on this NAT.
      Defaults is `"ALL"`.

  - **`subnetworks`**: _(Optional `list(subnetwork)`)_

    Configuration for logging on NAT.

    Default is `[]`.

    Each `subnetwork` object can have the following fields:

    - **`name`**: **_(Required `string`)_**

      Self-link of subnetwork to NAT.

    - **`source_ip_ranges_to_nat`**: **_(Required `string`)_**

      List of options for which source IPs in the subnetwork should have NAT enabled.

    - **`secondary_ip_range_names`**: _(Optional `string`)_

      List of the secondary ranges of the subnetwork that are allowed to use NAT.

      Default is `[]`.

## Module Attributes Reference

The following attributes are exported in the outputs of the module:

- **`module_enabled`**

  Whether this module is enabled.

- **`router`**
  The outputs of the created Cloud Router.

- **`nats`**

  The outputs of the create Cloud NATs.

## External Documentation

### Google Documentation:

- Router: <https://cloud.google.com/network-connectivity/docs/router>

### Terraform Google Provider Documentation:

- <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router>
- <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat>

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

[Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
that solves development, automation and security challenges in cloud infrastructure.

Our vision is to massively reduce time and overhead for teams to manage and
deploy production-grade and secure cloud infrastructure.

We offer commercial support for all of our modules and encourage you to reach out
if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
[Community Slack channel][slack].

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2020-2021 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-google-cloud-router
[hello@mineiros.io]: mailto:hello@mineiros.io

[badge-build]: https://github.com/mineiros-io/terraform-google-cloud-router/workflows/Tests/badge.svg

<!-- markdown-link-check-enable -->

[badge-semver]: https://img.shields.io/github/v/tag/mineiros-io/terraform-google-cloud-router.svg?label=latest&sort=semver
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[badge-terraform]: https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform
[badge-slack]: https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack

<!-- markdown-link-check-disabled -->

[build-status]: https://github.com/mineiros-io/terraform-google-cloud-router/actions
[releases-github]: https://github.com/mineiros-io/terraform-google-cloud-router/releases

<!-- markdown-link-check-enable -->

[releases-terraform]: https://github.com/hashicorp/terraform/releases
[badge-tf-gcp]: https://img.shields.io/badge/google-3.x-1A73E8.svg?logo=terraform
[releases-google-provider]: https://github.com/terraform-providers/terraform-provider-google/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[gcp]: https://cloud.google.com/
[semantic versioning (semver)]: https://semver.org/

<!-- markdown-link-check-disabled -->

[variables.tf]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-google-cloud-router/issues
[license]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-google-cloud-router/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/CONTRIBUTING.md

<!-- markdown-link-check-enable -->
