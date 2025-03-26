# Example Playbooks for Kubernetes cluster deployment with SIGHUP Distribution

In this directory we provide example playbooks for deploying a Kubernetes cluster using SIGHUP Distribution
to on-premises virtual machines at version 1.23.12 and then how to upgrade it to 1.24.7. The process is the same for the other supported Kuberntes versions.

- [Example Playbooks for Kubernetes cluster deployment with SIGHUP Distribution](#example-playbooks-for-kubernetes-cluster-deployment-with-sighup-distribution)
  - [Requirements](#requirements)
  - [Cluster Architecture](#cluster-architecture)
  - [Install phases](#install-phases)
    - [Initialize PKI](#initialize-pki)
    - [Install the Container Runtime](#install-the-container-runtime)
      - [Containerd](#containerd)
    - [Install the Load Balancer](#install-the-load-balancer)
    - [Provision Master and Worker Nodes](#provision-master-and-worker-nodes)
  - [Upgrade etcd cluster](#upgrade-etcd-cluster)
  - [Upgrade Kubernetes cluster](#upgrade-kubernetes-cluster)
  - [Utilities](#utilities)
    - [How to migrate from Docker to Containerd](#how-to-migrate-from-docker-to-containerd)
    - [How to renew Kubernetes PKI certificates](#how-to-renew-kubernetes-pki-certificates)

## Requirements

To be able to run the examples, you need to have the following software installed:

- ansible >= 2.8.0
- furyagent
- kubectl

One of the following supported Operating Systems on the target machines:

- Ubuntu
- RHEL
- Rocky
- Debian
- AlmaLinux

## Cluster Architecture

The cluster is composed of:

- 2 HAproxy load balancers
- 3 Master nodes
- 3 Worker nodes

In the default setup, we also deploy etcd on the control-plane nodes as a standalone systemd service. However, installation of the etcd cluster on dedicated nodes is also supported.

Check the following files for a complete example:

- `hosts.yaml`
- `haproxy.cfg`

> NOTE: all the cluster configuration is managed by hosts.ini and haproxy.cfg files.

## Install phases

The install phases are ordered, and each playbook has the order in which it should be run in the file name.

### Initialize PKI

First of all, we need to initialize CAs certificates for the etcd cluster and the Kubernetes components.
The initialization of the PKI is done locally, using `furyctl`:

```bash
furyctl create pki
```

As a result, a `./pki` directory with the following files will be created:

```text
pki
├── etcd
│  ├── ca.crt
│  └── ca.key
└── master
   ├── ca.crt
   ├── ca.key
   ├── front-proxy-ca.crt
   ├── front-proxy-ca.key
   ├── sa.key
   └── sa.pub
```

### Install the Container Runtime

In this step you can choose which container runtime you want to use:

- containerd

#### Containerd

Run the `1.containerd.yml` playbook with:

```bash
ansible-playbook 1.containerd.yml
```

### Install the Load Balancer

To install the load balancer run the `2.load-balancer.yml` playbook with:

```bash
ansible-playbook 2.load-balancer.yml
```

### Provision Master and Worker Nodes

Now that all the prerequisites are installed, we can provision the Kubernetes master and worker nodes.

The `3.cluster.yml` playbook needs some variables to be set in the `hosts.yaml` file, double-check that everything is ok.
There is also a commented example of the fields and variables needed to install etcd on separated nodes.

Run the playbook with:

```bash
ansible-playbook 3.cluster.yml
```

## Upgrade etcd cluster

Starting from version v1.32.x, in this folder there is a dedicated playbook to upgrade the etcd cluster.

You need to upgrade etcd version with the `54.upgrade-etcd.yaml` playbook with:

```bash
ansible-playbook 54.upgrade-etcd.yaml --limit etcd
```

## Upgrade Kubernetes cluster

In this folder there are two playbooks to upgrade the cluster to a new kubernetes version.

Change the `hosts.ini` with the version you want to upgrade to:

```yaml
all:
  vars:
    kubernetes_version: '1.24.7'
```

> NOTE: the `kubernetes_version` must be one of the versions available in the roles, i.e. supported by this installer.
<!-- spacer -->
> IMPORTANT: all the nodes must be in Ready status before running the upgrade.

First you need to upgrade the control plane with the `55.upgrade-control-plane.yml` playbook with:

```bash
ansible-playbook 55.upgrade-control-plane.yml
```

Then you need to upgrade the worker nodes with the `56.upgrade-worker-nodes.yml` playbook with:

```bash
ansible-playbook 56.upgrade-worker-nodes.yml --limit worker1
```

Repeat this step foreach worker node in the cluster.

> NOTE: you need to run the playbook with the `--limit` option to limit the nodes to upgrade. Why? Because the upgrade
> process will drain the node before upgrading it.
> Additionally, during the upgrade containerd will also be upgraded

## Utilities

### How to migrate from Docker to Containerd

To migrate from `docker` to `containerd`, there is an example playbook in this directory `99.migrate-docker-to-containerd.yml`.

It must be executed **one node at a time**:

```bash
ansible-playbook 99.migrate-docker-to-containerd.yml --limit worker1
```

### How to renew Kubernetes PKI certificates

This playbook automates the Kubernetes and etcd certificates renewal process, there is an example in this directory `98.cluster-certificates-renewal.yaml`.

```bash
ansible-playbook 98.cluster-certificates-renewal.yaml
```
