# CHANGELOG.md

This changelog documents deviations from the upstream [kube-bench](https://github.com/aquasecurity/kube-bench) CIS Kubernetes benchmark checks in our custom configuration.  
The aim is to transparently track **skipped** or **modified** controls due to environment-specific decisions, valid exceptions, or platform constraints.

## Summary of Changes

| Control ID(s)       | Status   | Notes                                                                                                                                  |
|---------------------|----------|----------------------------------------------------------------------------------------------------------------------------------------|
| 1.2.1               | Skipped  | Anonymous authentication is used for metrics scraping and is safe under proper RBAC                                                    |
| 1.2.11              | Skipped  | `AlwaysPullImages` cannot be enforced by default; CVE-related fix planned for Kubernetes 1.34                                          |
| 3.1.1               | Skipped  | Certificate-based authentication cannot be disabled by default                                                                         |
| 3.1.3               | Skipped  | Join token usage is limited to initial node bootstrap, making the control non-critical                                                 |
| 3.2.2               | Skipped  | The default audit policy already satisfies the CIS benchmark requirements                                                              |
| 4.2.9               | Skipped  | Kubelet certificate auto-rotation is enabled; setting `tls-cert-file` and `tls-private-key-file` conflicts with auto-rotation behavior |
| 4.2.14              | Skipped  | OS-level package and update management is considered out of scope for this benchmark configuration                                     |
| 1.1.9 / 1.1.10      | Changed  | Adjusted to use a custom CNI plugin path                                                                                               |

