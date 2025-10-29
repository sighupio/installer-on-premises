# On Premises module release vx.x.x

Welcome to the latest release of `on-premises` module of [`SIGHUP Distribution`](https://github.com/sighupio/distribution) maintained by SIGHUP by ReeVo team.

## Package Versions 🚢

### vx.x.x

| Package                                        | Supported Version | Previous Version |
| ---------------------------------------------- | ----------------- | ---------------- |
| [etcd](roles/etcd)                             | `3.5.21`          | `3.5.16`         |
| [haproxy](roles/haproxy)                       | `3.0`             | `No update`      |
| [containerd](roles/containerd)                 | `1.7.28`          | `1.7.26`         |
| [kube-node-common](roles/kube-node-common)     | `-`               | `Updated`        |
| [kube-control-plane](roles/kube-control-plane) | `-`               | `Updated`        |
| [kube-worker](roles/kube-worker)               | `-`               | `No update`      |

## New features 🌟

# Fixes
- [[#141](https://github.com/sighupio/installer-on-premises/pull/152)] **Do not hardcode etcd_binary_dir in etcd.service.j2**: Avoid hardcoding the etcd path inside the service in order to support setting a different download location.
    
## Breaking Changes 💔

## Update Guide 🦮

### Automatic upgrade using furyctl

To update using furyctl, follow this [documentation](https://docs.sighup.io/docs/installation/upgrades).

### Manual update
  
> NOTE: Each on-premises environment can be different, always double-check before updating components.

1. Update SD if applicable (see the [SD release notes](https://github.com/sighupio/distribution/tree/master/docs/releases))
2. Update the cluster using playbooks, see the examples in this repository to know more.
