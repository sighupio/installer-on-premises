# On Premises module release vTBD

Welcome to the latest release of `on-premises` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by SIGHUP by ReeVo team.

This release .... TBD

## Package Versions 🚢

### vTBD

| Package                                        | Supported Version | Previous Version |
| ---------------------------------------------- | ----------------- | ---------------- |
| [etcd](roles/etcd)                             | `3.5.16`          | `No update`      |
| [haproxy](roles/haproxy)                       | `3.0`             | `No update`      |
| [containerd](roles/containerd)                 | `1.7.26`          | `No update`      |
| [kube-node-common](roles/kube-node-common)     | `-`               | `No update`      |
| [kube-control-plane](roles/kube-control-plane) | `-`               | `No update`      |
| [kube-worker](roles/kube-worker)               | `-`               | `No update`      |

## Bug fixes 🐞

- [[#134](https://github.com/sighupio/installer-on-premises/pull/134)] Docker.io mirror: now configuring a mirror for docker.io does not result in an error anymore. Example, add the following vars to your Ansible `hosts.yaml` file:

```yaml
all:
  vars:
    containerd_registry_configs:
      - registry: docker.io
        mirror_endpoint:
          - https://mymirror.mycompany/v2/docker.io
```

## Update Guide 🦮

In this guide, we will try to summarize the update process to this release.

### Automatic upgrade using furyctl

To update using furyctl, follow this [documentation](https://docs.sighup.com/docs/installation/upgrades).

### Manual update
  
> NOTE: Each on-premises environment can be different, always double-check before updating components.

1. Update SD if applicable (see the [SD release notes](https://github.com/sighupio/distribution/tree/master/docs/releases))
2. Update the cluster using playbooks, see the examples in this repository to know more.
