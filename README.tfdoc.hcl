header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-google-cloud-router"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-google-cloud-router/workflows/Tests/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-google-cloud-router/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-google-cloud-router.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-google-cloud-router/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-gcp-provider" {
    image = "https://img.shields.io/badge/google-4-1A73E8.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-google/releases"
    text  = "Google Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-google-cloud-router"
  toc     = true
  content = <<-END
    A [Terraform] module for [Google Cloud Platform (GCP)][gcp].

    **_This module supports Terraform version 1
    and is compatible with the Terraform Google Provider version 4._** and 5._**

    This module is part of our Infrastructure as Code (IaC) framework
    that enables our users and customers to easily deploy and manage reusable,
    secure, and production-grade cloud infrastructure.
  END

  section {
    title   = "Module Features"
    content = <<-END
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
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most basic usage just setting required arguments:

      ```hcl
      module "terraform-google-cloud-router" {
        source = "github.com/mineiros-io/terraform-google-cloud-router.git?ref=v0.0.2"
      }
      ```
    END
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Top-level Arguments"

      section {
        title = "Module Configuration"

        variable "module_enabled" {
          type        = bool
          default     = true
          description = <<-END
            Specifies whether resources in the module will be created.
          END
        }

        variable "module_depends_on" {
          type           = list(dependency)
          description    = <<-END
            A list of dependencies. Any object can be _assigned_ to this list to define a hidden external dependency.
          END
          readme_example = <<-END
            module_depends_on = [
              google_network.network
            ]
          END
        }
      }

      section {
        title = "Main Resource Configuration"

        variable "region" {
          required    = true
          type        = string
          description = <<-END
            The region to host the VPC and all related resources in.
          END
        }

        variable "network" {
          required    = true
          type        = string
          description = <<-END
            A reference to the network to which this router belongs.
          END
        }

        variable "project" {
          type        = string
          description = <<-END
            The ID of the project in which the resource belongs. If it is not set, the provider project is used.
          END
        }

        variable "name" {
          type        = string
          default     = "main"
          description = <<-END
            Name of the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `'[a-z]([-a-z0-9]*[a-z0-9])?'` which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash.
          END
        }

        variable "bgp" {
          type           = object(bgp)
          description    = <<-END
            BGP information specific to this router.

              Each `bgp` object can have the following fields:
          END
          readme_example = <<-END
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
          END

          attribute "asn" {
            required    = true
            type        = string
            description = <<-END
              Local BGP Autonomous System Number `(ASN)`. Must be an RFC6996 private ASN, either `16-bit` or `32-bit`. The value will be fixed for this router resource. All VPN tunnels that link to this router will have the same local ASN.
            END
          }

          attribute "advertise_mode" {
            type        = string
            default     = "DEFAULT"
            description = <<-END
              User-specified flag to indicate which mode to use for advertisement. Possible values are `DEFAULT` and `CUSTOM`.
            END
          }

          attribute "advertised_groups" {
            type        = list(string)
            default     = []
            description = <<-END
              User-specified list of prefix groups to advertise in custom mode. This field can only be populated if advertiseMode is `CUSTOM` and is advertised to all peers of the router. These groups will be advertised in addition to any specified prefixes. Leave this field blank to advertise no custom groups. This enum field has the one valid value: `ALL_SUBNETS`
            END
          }

          attribute "advertised_ip_ranges" {
            type        = list(advertised_ip_range)
            default     = []
            description = <<-END
              User-specified list of individual IP ranges to advertise in custom mode. This field can only be populated if advertiseMode is `CUSTOM` and is advertised to all peers of the router. These IP ranges will be advertised in addition to any specified groups. Leave this field blank to advertise no custom IP ranges.
            END

            attribute "range" {
              required    = true
              type        = string
              description = <<-END
                The IP range to advertise. The value must be a CIDR-formatted string.
              END
            }

            attribute "description" {
              type        = string
              description = <<-END
                User-specified description for the IP range.
              END
            }
          }
        }
      }

      section {
        title = "Extended Resource Configuration"

        section {
          title = "Terraform google cloud router nat"

          variable "nats" {
            type        = list(nat)
            default     = []
            description = <<-END
              NATs to deploy on this router.
            END

            attribute "name" {
              required    = true
              type        = string
              description = <<-END
                Name of the NAT.
              END
            }

            attribute "nat_ip_allocate_option" {
              type        = string
              default     = "AUTO_ONLY"
              description = <<-END
                How external IPs should be allocated for this NAT.
              END
            }

            attribute "source_subnetwork_ip_ranges_to_nat" {
              type        = string
              default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
              description = <<-END
                How NAT should be configured per Subnetwork.
              END
            }

            attribute "nat_ips" {
              type        = list(number)
              description = <<-END
                Self-links of NAT IPs. Only valid if `natIpAllocateOption` is set to MANUAL_ONLY.
              END
            }

            attribute "min_ports_per_vm" {
              type        = number
              description = <<-END
                Minimum number of ports allocated to a VM from this NAT.
              END
            }

            attribute "udp_idle_timeout_sec" {
              type        = number
              default     = 30
              description = <<-END
                Timeout (in seconds) for UDP connections.
              END
            }

            attribute "icmp_idle_timeout_sec" {
              type        = number
              default     = 30
              description = <<-END
                Timeout (in seconds) for ICMP connections.
              END
            }

            attribute "tcp_established_idle_timeout_sec" {
              type        = number
              default     = 1200
              description = <<-END
                Timeout (in seconds) for TCP established connections.
              END
            }

            attribute "tcp_transitory_idle_timeout_sec" {
              type        = number
              default     = 30
              description = <<-END
                Timeout (in seconds) for TCP transitory connections.
              END
            }

            attribute "log_config" {
              type        = object(log_config)
              default     = []
              description = <<-END
                Configuration for logging on NAT.
              END

              attribute "enabled" {
                required    = true
                type        = bool
                default     = true
                description = <<-END
                  Indicates whether or not to export logs.
                END
              }

              attribute "filter" {
                required    = true
                type        = string
                default     = "ALL"
                description = <<-END
                  Specifies the desired filtering of logs on this NAT.
                END
              }
            }

            attribute "subnetworks" {
              type        = list(subnetwork)
              default     = []
              description = <<-END
                Configuration for logging on NAT.
              END

              attribute "name" {
                required    = true
                type        = string
                description = <<-END
                  Self-link of subnetwork to NAT.
                END
              }

              attribute "source_ip_ranges_to_nat" {
                required    = true
                type        = string
                description = <<-END
                  List of options for which source IPs in the subnetwork should have NAT enabled.
                END
              }

              attribute "secondary_ip_range_names" {
                type        = string
                default     = "[]"
                description = <<-END
                  List of the secondary ranges of the subnetwork that are allowed to use NAT.
                END
              }
            }
          }
        }
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported in the outputs of the module:
    END

    output "module_enabled" {
      type        = bool
      description = <<-END
        Whether this module is enabled.
      END
    }

    output "router" {
      type        = object(router)
      description = <<-END
        The outputs of the created Cloud Router.
      END
    }

    output "nats" {
      type        = list(nat)
      description = <<-END
        The outputs of the create Cloud NATs.
      END
    }
  }

  section {
    title = "External Documentation"

    section {
      title   = "Google Documentation"
      content = <<-END
        - Router: <https://cloud.google.com/network-connectivity/docs/router>
      END
    }

    section {
      title   = "Terraform Google Provider Documentation"
      content = <<-END
        - <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router>
        - <https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat>
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      [Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
      that solves development, automation and security challenges in cloud infrastructure.

      Our vision is to massively reduce time and overhead for teams to manage and
      deploy production-grade and secure cloud infrastructure.

      We offer commercial support for all of our modules and encourage you to reach out
      if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
      [Community Slack channel][slack].
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-google-cloud-router"
  }
  ref "hello@mineiros.io" {
    value = "mailto:hello@mineiros.io"
  }
  ref "badge-build" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/workflows/Tests/badge.svg"
  }
  ref "badge-semver" {
    value = "https://img.shields.io/github/v/tag/mineiros-io/terraform-google-cloud-router.svg?label=latest&sort=semver"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "badge-terraform" {
    value = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
  }
  ref "badge-slack" {
    value = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
  }
  ref "build-status" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/actions"
  }
  ref "releases-github" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/releases"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "badge-tf-gcp" {
    value = "https://img.shields.io/badge/google-3.x-1A73E8.svg?logo=terraform"
  }
  ref "releases-google-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-google/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://mineiros.io/slack"
  }
  ref "terraform" {
    value = "https://www.terraform.io"
  }
  ref "gcp" {
    value = "https://cloud.google.com/"
  }
  ref "semantic versioning (semver)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/examples"
  }
  ref "issues" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/issues"
  }
  ref "license" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/LICENSE"
  }
  ref "makefile" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/Makefile"
  }
  ref "pull requests" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/pulls"
  }
  ref "contribution guidelines" {
    value = "https://github.com/mineiros-io/terraform-google-cloud-router/blob/main/CONTRIBUTING.md"
  }
}
