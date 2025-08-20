<!-- markdownlint-disable MD033 -->
<h1 align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png">
  <img alt="Shows a black logo in light color mode and a white one in dark color mode." src="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
</picture><br/>
  On-Premises Installer
</h1>
<!-- markdownlint-enable MD033 -->

![Release](https://img.shields.io/badge/Latest%20Release-v1.32.4--rev.2-blue)
![License](https://img.shields.io/github/license/sighupio/installer-on-premises?label=License)
![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack&label=Slack)

<!-- <SD-DOCS> -->

**On-Premises Installer** is an installer and add-on module for the [SIGHUP Distribution (SD)][sd-repo] that provides
packages to install Kubernetes to a set of existing VMs.

If you are new to SD please refer to the [official documentation][sd-docs] on how to get started with SD.

## Overview

**On-Premises Installer** uses a collection of open source tools to install Kubernetes in a set of existing VM (usually, an on-premises environment).

## Packages

The following packages are included in the Fury Kubernetes on-premises module:

| Package                                        | Version  | Description                                                                   |
| ---------------------------------------------- | -------- | ----------------------------------------------------------------------------- |
| [etcd](roles/etcd)                             | `3.5.16` | Ansible role to install etcd as systemd service                               |
| [haproxy](roles/haproxy)                       | `3.0`    | Ansible role to install HAProxy as Kubernetes load balancer for the APIServer |
| [containerd](roles/containerd)                 | `1.7.26` | Ansible role to install containerd as container runtime                       |
| [kube-node-common](roles/kube-node-common)     | `-`      | Ansible role to install prerequisites for Kubernetes setup                    |
| [kube-control-plane](roles/kube-control-plane) | `-`      | Ansible role to install control-plane nodes                                   |
| [kube-worker](roles/kube-worker)               | `-`      | Ansible role to install worker nodes and join them to the cluster             |

Click on each package to see its full documentation.

## Compatibility

This version is compatible with Kubernetes 1.32.4 plus the complete list in the compatibility matrix.

Check the [compatibility matrix][compatibility-matrix] for additional information about previous releases of the module.

> [!WARNING]
> Support for the ARM platform is still in beta status, the Load Balancers installed with the `haproxy` role are not currently supported for RHEL and RHEL derivatives running on ARM. Please use a different OS for the Load Balancers VMs (or disable them and create your own load balancer).

## Usage

### Prerequisites

| Tool                    | Version    | Description                                                                                                                                                |
| ----------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [furyctl][furyctl-repo] | `>=0.32.0` | The recommended tool to download and manage SD modules and their packages. To learn more about `furyctl` read the [official documentation][furyctl-repo]. |

### Legacy provisioning

> [!TIP]
> Clusters are now being totally managed by [`furyctl`][furyctl-repo] with the OnPremises provider, the following example is for a manual install.
>
> Check the [getting-started][getting-started] documentation to know more on how to create a cluster with furyctl.

1. List the role in a `Furyfile.yml` file

```yaml
roles:
  - name: on-premises
    version: v1.32.4-rev.2
```

1. Execute `furyctl legacy vendor -H` to download the roles

2. Inspect the downloaded roles inside `./vendor/roles/on-premise`

3. Install Kubernetes cluster using the downloaded roles. You can use our [example playbooks](examples/playbooks)

<!-- Links -->

[furyctl-repo]: https://github.com/sighupio/furyctl
[compatibility-matrix]: https://github.com/sighupio/fury-kubernetes-on-premises/blob/master/docs/COMPATIBILITY_MATRIX.md
[sd-repo]: https://github.com/sighupio/fury-distribution
[sd-docs]: https://docs.kubernetesfury.com/docs/distribution/
[getting-started]: https://docs.kubernetesfury.com/docs/getting-started/fury-on-vms

<!-- </SD-DOCS> -->

<!-- <FOOTER> -->

### Reporting Issues

In case you experience any problems with the module, please [open a new issue](https://github.com/sighupio/installer-on-premises/issues/new/choose).

## License

This module is open-source and it's released under the following [LICENSE](LICENSE).

<!-- </FOOTER> -->
