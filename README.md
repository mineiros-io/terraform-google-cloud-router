[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>](https://mineiros.io/?ref=terraform-google-cloud-router)

[![Build Status](https://github.com/mineiros-io/terraform-google-cloud-router/workflows/Tests/badge.svg)](https://github.com/mineiros-io/terraform-google-cloud-router/actions)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-google-cloud-router.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-google-cloud-router/releases)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![Google Provider Version](https://img.shields.io/badge/google-4-1A73E8.svg?logo=terraform)](https://github.com/terraform-providers/terraform-provider-google/releases)
[![Join Slack](https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack)](https://mineiros.io/slack)

# terraform-google-cloud-router

A [Terraform] module for [Google Cloud Platform (GCP)][gcp].

**_This module supports Terraform version 1
and is compatible with the Terraform Google Provider version 4._**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.


- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Top-level Arguments](#top-level-arguments)
    - [Module Configuration](#module-configuration)
    - [Main Resource Configuration](#main-resource-configuration)
    - [Extended Resource Configuration](#extended-resource-configuration)
      - [Terraform google cloud router nat](#terraform-google-cloud-router-nat)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [Google Documentation](#google-documentation)
  - [Terraform Google Provider Documentation](#terraform-google-provider-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

A [Terraform] base module for creating a `google_compute_router` resource. This module creates another resource  `google_compute_router_nat` to create a more comprehensive google cloud router module.

<!--
These are some of our custom features:

- **Default Security Settings**:
  secure by default by setting security to `true`, additional security can be added by setting some feature to `enabled`

- **Standard Module Features**:
  Cool Feature of the main resource, tags

- **Extended Module Features**:
  Awesome Extended Feature of an additional related resource,
  and another Cool Feature

- **Additional Features**:
  a Cool Feature that is not actually a resource but a cool set up from us

- _Features not yet implemented_:
  Standard Features missing,
  Extended Features planned,
  Additional Features planned
-->

## Getting Started

Most basic usage just setting required arguments:

```hcl
module "terraform-google-cloud-router" {
  source = "github.com/mineiros-io/terraform-google-cloud-router.git?ref=v0.1.0"
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Top-level Arguments

#### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

- [**`module_depends_on`**](#var-module_depends_on): *(Optional `list(dependency)`)*<a name="var-module_depends_on"></a>

  A list of dependencies. Any object can be _assigned_ to this list to define a hidden external dependency.

  Example:

  ```hcl
  module_depends_on = [
    google_network.network
  ]
  ```

#### Main Resource Configuration

- [**`region`**](#var-region): *(**Required** `string`)*<a name="var-region"></a>

  The region to host the VPC and all related resources in.

- [**`network`**](#var-network): *(**Required** `string`)*<a name="var-network"></a>

  A reference to the network to which this router belongs.

- [**`project`**](#var-project): *(Optional `string`)*<a name="var-project"></a>

  The ID of the project in which the resource belongs. If it is not set, the provider project is used.

- [**`name`**](#var-name): *(Optional `string`)*<a name="var-name"></a>

  Name of the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `'[a-z]([-a-z0-9]*[a-z0-9])?'` which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash.

  Default is `"main"`.

- [**`bgp`**](#var-bgp): *(Optional `object(bgp)`)*<a name="var-bgp"></a>

  BGP information specific to this router.

    Each `bgp` object can have the following fields:

  Example:

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

  The `bgp` object accepts the following attributes:

  - [**`asn`**](#attr-bgp-asn): *(**Required** `string`)*<a name="attr-bgp-asn"></a>

    Local BGP Autonomous System Number `(ASN)`. Must be an RFC6996 private ASN, either `16-bit` or `32-bit`. The value will be fixed for this router resource. All VPN tunnels that link to this router will have the same local ASN.

  - [**`advertise_mode`**](#attr-bgp-advertise_mode): *(Optional `string`)*<a name="attr-bgp-advertise_mode"></a>

    User-specified flag to indicate which mode to use for advertisement. Possible values are `DEFAULT` and `CUSTOM`.

    Default is `"DEFAULT"`.

  - [**`advertised_groups`**](#attr-bgp-advertised_groups): *(Optional `list(string)`)*<a name="attr-bgp-advertised_groups"></a>

    User-specified list of prefix groups to advertise in custom mode. This field can only be populated if advertiseMode is `CUSTOM` and is advertised to all peers of the router. These groups will be advertised in addition to any specified prefixes. Leave this field blank to advertise no custom groups. This enum field has the one valid value: `ALL_SUBNETS`

    Default is `[]`.

  - [**`advertised_ip_ranges`**](#attr-bgp-advertised_ip_ranges): *(Optional `list(advertised_ip_range)`)*<a name="attr-bgp-advertised_ip_ranges"></a>

    User-specified list of individual IP ranges to advertise in custom mode. This field can only be populated if advertiseMode is `CUSTOM` and is advertised to all peers of the router. These IP ranges will be advertised in addition to any specified groups. Leave this field blank to advertise no custom IP ranges.

    Default is `[]`.

    Each `advertised_ip_range` object in the list accepts the following attributes:

    - [**`range`**](#attr-bgp-advertised_ip_ranges-range): *(**Required** `string`)*<a name="attr-bgp-advertised_ip_ranges-range"></a>

      The IP range to advertise. The value must be a CIDR-formatted string.

    - [**`description`**](#attr-bgp-advertised_ip_ranges-description): *(Optional `string`)*<a name="attr-bgp-advertised_ip_ranges-description"></a>

      User-specified description for the IP range.

#### Extended Resource Configuration

##### Terraform google cloud router nat

- [**`nats`**](#var-nats): *(Optional `list(nat)`)*<a name="var-nats"></a>

  NATs to deploy on this router.

  Default is `[]`.

  Each `nat` object in the list accepts the following attributes:

  - [**`name`**](#attr-nats-name): *(**Required** `string`)*<a name="attr-nats-name"></a>

    Name of the NAT.

  - [**`nat_ip_allocate_option`**](#attr-nats-nat_ip_allocate_option): *(Optional `string`)*<a name="attr-nats-nat_ip_allocate_option"></a>

    How external IPs should be allocated for this NAT.

    Default is `"AUTO_ONLY"`.

  - [**`source_subnetwork_ip_ranges_to_nat`**](#attr-nats-source_subnetwork_ip_ranges_to_nat): *(Optional `string`)*<a name="attr-nats-source_subnetwork_ip_ranges_to_nat"></a>

    How NAT should be configured per Subnetwork.

    Default is `"ALL_SUBNETWORKS_ALL_IP_RANGES"`.

  - [**`nat_ips`**](#attr-nats-nat_ips): *(Optional `list(number)`)*<a name="attr-nats-nat_ips"></a>

    Self-links of NAT IPs. Only valid if `natIpAllocateOption` is set to MANUAL_ONLY.

  - [**`min_ports_per_vm`**](#attr-nats-min_ports_per_vm): *(Optional `number`)*<a name="attr-nats-min_ports_per_vm"></a>

    Minimum number of ports allocated to a VM from this NAT.

  - [**`udp_idle_timeout_sec`**](#attr-nats-udp_idle_timeout_sec): *(Optional `number`)*<a name="attr-nats-udp_idle_timeout_sec"></a>

    Timeout (in seconds) for UDP connections.

    Default is `30`.

  - [**`icmp_idle_timeout_sec`**](#attr-nats-icmp_idle_timeout_sec): *(Optional `number`)*<a name="attr-nats-icmp_idle_timeout_sec"></a>

    Timeout (in seconds) for ICMP connections.

    Default is `30`.

  - [**`tcp_established_idle_timeout_sec`**](#attr-nats-tcp_established_idle_timeout_sec): *(Optional `number`)*<a name="attr-nats-tcp_established_idle_timeout_sec"></a>

    Timeout (in seconds) for TCP established connections.

    Default is `1200`.

  - [**`tcp_transitory_idle_timeout_sec`**](#attr-nats-tcp_transitory_idle_timeout_sec): *(Optional `number`)*<a name="attr-nats-tcp_transitory_idle_timeout_sec"></a>

    Timeout (in seconds) for TCP transitory connections.

    Default is `30`.

  - [**`log_config`**](#attr-nats-log_config): *(Optional `object(log_config)`)*<a name="attr-nats-log_config"></a>

    Configuration for logging on NAT.

    Default is `[]`.

    The `log_config` object accepts the following attributes:

    - [**`enabled`**](#attr-nats-log_config-enabled): *(**Required** `bool`)*<a name="attr-nats-log_config-enabled"></a>

      Indicates whether or not to export logs.

      Default is `true`.

    - [**`filter`**](#attr-nats-log_config-filter): *(**Required** `string`)*<a name="attr-nats-log_config-filter"></a>

      Specifies the desired filtering of logs on this NAT.

      Default is `"ALL"`.

  - [**`subnetworks`**](#attr-nats-subnetworks): *(Optional `list(subnetwork)`)*<a name="attr-nats-subnetworks"></a>

    Configuration for logging on NAT.

    Default is `[]`.

    Each `subnetwork` object in the list accepts the following attributes:

    - [**`name`**](#attr-nats-subnetworks-name): *(**Required** `string`)*<a name="attr-nats-subnetworks-name"></a>

      Self-link of subnetwork to NAT.

    - [**`source_ip_ranges_to_nat`**](#attr-nats-subnetworks-source_ip_ranges_to_nat): *(**Required** `string`)*<a name="attr-nats-subnetworks-source_ip_ranges_to_nat"></a>

      List of options for which source IPs in the subnetwork should have NAT enabled.

    - [**`secondary_ip_range_names`**](#attr-nats-subnetworks-secondary_ip_range_names): *(Optional `string`)*<a name="attr-nats-subnetworks-secondary_ip_range_names"></a>

      List of the secondary ranges of the subnetwork that are allowed to use NAT.

      Default is `"[]"`.

## Module Outputs

The following attributes are exported in the outputs of the module:

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

- [**`router`**](#output-router): *(`object(router)`)*<a name="output-router"></a>

  The outputs of the created Cloud Router.

- [**`nats`**](#output-nats): *(`list(nat)`)*<a name="output-nats"></a>

  The outputs of the create Cloud NATs.

## External Documentation

### Google Documentation

- Router: <https://cloud.google.com/network-connectivity/docs/router>

### Terraform Google Provider Documentation

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

Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-google-cloud-router
[hello@mineiros.io]: mailto:hello@mineiros.io
[badge-build]: https://github.com/mineiros-io/terraform-google-cloud-router/workflows/Tests/badge.svg
[badge-semver]: https://img.shields.io/github/v/tag/mineiros-io/terraform-google-cloud-router.svg?label=latest&sort=semver
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[badge-terraform]: https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform
[badge-slack]: https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack
[build-status]: https://github.com/mineiros-io/terraform-google-cloud-router/actions
[releases-github]: https://github.com/mineiros-io/terraform-google-cloud-router/releases
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[badge-tf-gcp]: https://img.shields.io/badge/google-3.x-1A73E8.svg?logo=terraform
[releases-google-provider]: https://github.com/terraform-providers/terraform-provider-google/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[gcp]: https://cloud.google.com/
[semantic versioning (semver)]: https://semver.org/
[variables.tf]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-google-cloud-router/issues
[license]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-google-cloud-router/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/CONTRIBUTING.md
