# CHANGELOG.md

This changelog documents deviations from the upstream [kube-bench](https://github.com/aquasecurity/kube-bench) CIS Kubernetes benchmark checks in our custom configuration, as well as the current kube-bench results.
The aim is to transparently track **skipped** or **modified** controls due to environment-specific decisions, valid exceptions, or platform constraints.

## cis-1.12 (Kubernetes 1.32, 1.33, 1.34, 1.35)

Introduced cis-1.12 configuration, based on the upstream kube-bench `cis-1.12` rule set. All customizations from cis-1.11 are carried forward unchanged, with the following differences from upstream:

| Control ID(s)       | Status   | Notes                                                                                                                                  |
|---------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------|
| 1.1.7 / 1.1.8      | Skipped  | No pod specification file for etcd; etcd runs as a systemd service                                                                    |
| 1.1.9 / 1.1.10     | Changed  | Adjusted to use a custom CNI plugin path (`/var/lib/cni` instead of `/var/lib/cni/networks`)                                          |
| 1.2.1               | Skipped  | Anonymous authentication is used for metrics scraping and is safe under proper RBAC                                                    |
| 1.2.11              | Skipped  | `AlwaysPullImages` cannot be enforced by default; note that from K8s 1.35 the security concern this check addresses is mitigated by `KubeletEnsureSecretPulledImages` (KEP-2862, default since 1.35) |
| 3.1.1               | Skipped  | Certificate-based authentication cannot be disabled by default                                                                         |
| 3.1.3               | Skipped  | Join token usage is limited to initial node bootstrap, making the control non-critical                                                 |
| 3.2.2               | Skipped  | The default audit policy already satisfies the CIS benchmark requirements                                                              |
| 4.1.3 / 4.1.4       | Skipped  | kube-proxy runs as a DaemonSet in kube-system; no proxy kubeconfig file is present on nodes                                           |
| 4.2.9               | Skipped  | Kubelet certificate auto-rotation is enabled; setting `tls-cert-file` and `tls-private-key-file` conflicts with auto-rotation behavior |
| 4.2.14              | Skipped  | OS-level package and update management is considered out of scope for this benchmark configuration                                     |

**Changes vs cis-1.11:**
- **4.2.15 removed upstream**: the `--IPAddressDeny` check (which was in cis-1.11 and noted as "not yet adopted") was dropped by the CIS/kube-bench upstream in cis-1.12. No action needed.
- **policies.yaml 5.2.9 removed upstream**: the automated "Minimize the admission of containers with added capabilities" check was dropped; 5.2.10–5.2.13 renumbered to 5.2.9–5.2.12.

## Summary of Changes

| Control ID(s)       | Status   | Notes                                                                                                                                  |
|---------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------|
| 1.1.9 / 1.1.10      | Changed  | Adjusted to use a custom CNI plugin path                                                                                               |
| 1.2.1               | Skipped  | Anonymous authentication is used for metrics scraping and is safe under proper RBAC                                                    |
| 1.2.11              | Skipped  | `AlwaysPullImages` cannot be enforced by default by the installer; from K8s 1.35 the security concern this check addresses is mitigated by `KubeletEnsureSecretPulledImages` (KEP-2862)                                      |
| 3.1.1               | Skipped  | Certificate-based authentication cannot be disabled by default                                                                         |
| 3.1.3               | Skipped  | Join token usage is limited to initial node bootstrap, making the control non-critical                                                 |
| 3.2.2               | Skipped  | The default audit policy already satisfies the CIS benchmark requirements                                                              |
| 4.2.9               | Skipped  | Kubelet certificate auto-rotation is enabled; setting `tls-cert-file` and `tls-private-key-file` conflicts with auto-rotation behavior |
| 4.2.14              | Skipped  | OS-level package and update management is considered out of scope for this benchmark configuration                                     |

## Current Status

| ID    | Check (summary)                                | Status | Motivation |
|-------|------------------------------------------------|--------|-------------------------|
| 1.1.7 | Ensure correct permissions on etcd pod manifest | INFO   | No pod specification file, since etcd runs as systemd service in our cluster |
| 1.1.8| Ensure correct ownership on etcd pod manifest  | INFO   | No pod specification file, since etcd runs as systemd service in our cluster |
| 1.2.1 | Anonymos authentication set to false           | INFO   | Anonymous authentication used for metrics scraping is safe under proper RBAC|
| 1.2.11| Admission plugin AlwaysPullImages              | INFO   | AlwaysPullImages cannot be enforced by default |
| 1.2.27| Encryption provider config                     | WARN   | The distribution can be configured to enable encryption at rest using the related field [encryption configuration][etcd-encryption]. We leave encryption provider selection and key management to the cluster administrator |
| 1.2.28| Encryption providers properly configured       | WARN   | The distribution can be configured to enable encryption at rest using the related field [encryption configuration][etcd-encryption]. We leave encryption provider selection and key management to the cluster administrator |
| 3.1.1 | Client certificate authentication for users    | INFO   | Certificate-based auth cannot be disabled by default |
| 3.1.2 | Service account token authentication for users | WARN   | Best-practices suggestion, not scored. Policies already in place |
| 3.1.3 | Bootstrap token authentication for users       | INFO   | Join token usage is limited to node bootstrap only |
| 3.2.2 | Audit policy coverage                          | INFO   | Default audit policy already satisfies benchmark requirements |
| 4.1.3 | Ensure correct permissions on proxy kubeconfig file | INFO   | kube-proxy runs as a DaemonSet in the kube-system namespace, not as a local service. No proxy kubeconfig file is present on the nodes |
| 4.1.4 | Ensure correct ownership for proxy kubeconfig file | INFO   | kube-proxy runs as a DaemonSet in the kube-system namespace, not as a local service. No proxy kubeconfig file is present on the nodes |
| 4.2.7 | Ensure that the `hostname-override` argument is not set | WARN  | Required for kubeadm-based clusters where system hostname differs from FQDN. Nodes are registered with DNS-aligned names (e.g. `master1.k8s.local`) and TLS certificates, ensuring secure identity. |
| 4.2.9 | Kubelet TLS certificate and key file           | INFO   | Rotation of kubelet server certificates is enabled (4.2.11 PASS). Explicitly setting `tls-cert-file` and `tls-private-key-file` is unnecessary and would conflict with auto-rotation |
| 4.2.14| Ensure that the `seccomp-default` parameter is set to true | INFO | OS management is out of scope. Core system pods already run with the `RuntimeDefault` seccomp profile, which provides baseline syscall filtering from the container runtime |
| 4.2.15| Ensure that the `IPAddressDeny` is set to any | N/A  | Was introduced in CIS 1.11 and removed in CIS 1.12 upstream. No action required. |
