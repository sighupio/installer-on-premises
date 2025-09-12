# Installing and Using `kube-bench`

[`kube-bench`](https://github.com/aquasecurity/kube-bench) is a security auditing tool that checks whether Kubernetes is deployed according to the CIS Kubernetes Benchmark.

## Prerequisites

- Access to a Kubernetes cluster
- `kubectl` installed and configured
- Sufficient permissions to run pods and access node information

## Installation & Usage

You can install `kube-bench` downloading its release binary or using a container image.

### Option 1: Download and execute

Downloads the `kube-bench` tool defining the desired version:

```bash
KUBE_BENCH_VERSION=0.12.0

curl -L https://github.com/aquasecurity/kube-bench/releases/download/v${KUBE_BENCH_VERSION}/kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz -o kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz

tar -xvf kube-bench_${KUBE_BENCH_VERSION}_linux_amd64.tar.gz
```

Then, you can execute it:

```bash
./kube-bench
```

You can also execute it passing the configuration to use:
```bash
./kube-bench --config /etc/kube-bench/cfg/config.yaml
```

### Option 2: Run as a Kubernetes Job

> Replace `<VERSION>` with the desired kube-bench version (e.g., `0.12.0`)

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/<VERSION>/job.yaml
```

## Sources and Refs

For more information see [here](https://github.com/aquasecurity/kube-bench/blob/main/docs/installation.md).