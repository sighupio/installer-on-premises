# On Premises module release vTBD

Welcome to the latest release of `on-premises` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by SIGHUP by ReeVo team.

This release adds two new features to the kube-control-plane role.

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

## New features 🌟

- [[#137](https://github.com/sighupio/installer-on-premises/pull/137)]: Adds two new variables to the `kube-control-plane` role that allows skipping kubeadm phases and setting taints for the control-plane nodes on creation time.

```yaml
# hosts.ini
all:
  children:
    master:
      vars:
        kubeadm_skip_phases: "addon/kube-proxy" # skip kube-proxy installation
        kubernetes_taints: [] # don't add the default control-plane taints to the nodes
```

## Bug fixes 🐞


## Update Guide 🦮

In this guide, we will try to summarize the update process to this release.

### Automatic upgrade using furyctl

To update using furyctl, follow this [documentation](https://docs.sighup.com/docs/installation/upgrades).

### Manual update
  
> NOTE: Each on-premises environment can be different, always double-check before updating components.

1. Update SD if applicable (see the [SD release notes](https://github.com/sighupio/distribution/tree/master/docs/releases))
2. Update the cluster using playbooks, see the examples in this repository to know more.
