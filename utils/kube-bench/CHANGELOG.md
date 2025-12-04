# CHANGELOG.md

This changelog documents deviations from the upstream [kube-bench](https://github.com/aquasecurity/kube-bench) CIS Kubernetes benchmark checks in our custom configuration, as well as the current kube-bench results.
The aim is to transparently track **skipped** or **modified** controls due to environment-specific decisions, valid exceptions, or platform constraints.

## Summary of Changes

| Control ID(s)       | Status   | Notes                                                                                                                                  |
|---------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------|
| 1.1.9 / 1.1.10      | Changed  | Adjusted to use a custom CNI plugin path                                                                                               |
| 1.2.1               | Skipped  | Anonymous authentication is used for metrics scraping and is safe under proper RBAC                                                    |
| 1.2.11              | Skipped  | `AlwaysPullImages` cannot be enforced by default; CVE-related fix planned for Kubernetes 1.34                                          |
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
| 1.2.11| Admission plugin AlwaysPullImages              | INFO   | AlwaysPullImages cannot be enforced by default; Waiting for upstream K8s release 1.34, where this issue will be addressed |
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
| 4.2.15| Ensure that the `IPAddressDeny` is set to any | WARN | New check introduced in CIS 1.11. Not yet adopted in SD on-premises installer, as it requires explicitly managing kubelet’s allowed IPs (API server, node, pod subnets). Will be evaluated and addressed in future releases. |
