# On-Premises Installer Maintenance Guide

This document describes the steps for releasing new versions of the SIGHUP Distribution on-premises installer.

## Overview

We evaluate case by case whether to remove support for older versions, considering deprecations or other factors for each release.

## Release Process

Releasing a new version requires updating two repositories: the SIGHUP Distribution on-premises installer project (this repository) and the SIGHUP Distribution project.

### installer-on-premises

1. **Containerd**: define the target Kubernetes version (e.g., vX.Y.Z) - check GitHub releases.
   - Also define supported versions (e.g., X.Y-1.Z, X.Y-n.Z).
   - Add version blocks under `versions` in the containerd role in `defaults/main.yaml`.
   - Within these blocks, update the versions of containerd, runc, and sandbox image.
   - Search the docs for the containerd version, then check the comments in `defaults/main.yaml` for containerd with URLs to verify the other two components.

2. **Etcd**: update the `etcd_version` in `defaults/main.yaml` (always verify against the [Go constants file](https://github.com/kubernetes/kubernetes/blob/vX.Y.Z/cmd/kubeadm/app/constants/constants.go)).

3. **HA Proxy**: bump the version in `defaults/main.yaml` (check upstream repositories).

4. **Kube-worker**: no action required.

5. **Kube-node-common**: 
   - In `defaults/main.yaml`, bump the versions in `kubernetes_version`.
   - Add the 3 versions to the "dependencies" object (1 new + the n supported ones).
   - Verify `cri_tools` using the [compatibility matrix](https://github.com/kubernetes-sigs/cri-tools?tab=readme-ov-file#compatibility-matrix-cri-tools--kubernetes).

6. **Kube-control-plane**: update the Kubernetes versions in `defaults/main.yaml` in `dependencies` and the default version in `kubernetes_version`.

7. **Documentation**:
   - Update the main `README.md` with the new supported Kubernetes versions.
   - Update the `COMPATIBILITY_MATRIX.md`.
   - Create a new release file at `./docs/releases/vX.Y.Z.md` documenting the changes.

8. **Image Sync**: update container images in the [container-image-sync repository](https://github.com/sighupio/container-image-sync/blob/main/modules/on-premises/images.yml):
   - **CoreDNS**: update version using the [CoreDNS compatibility matrix](https://github.com/coredns/deployment/blob/master/kubernetes/CoreDNS-k8s_version.md).
   - **Kubernetes components**: update all core Kubernetes component images.
   - **Pause**: update the sandbox image if needed.

9. **Initial Testing**: perform initials tests.

10. **Tagging**: create the release candidate tag `vX.Y.Z-rc.0`.

> [!NOTE]
> You can stop here if you only need to update the installer without releasing a new SIGHUP Distribution version. Continue with steps 11-12 only when performing a full distribution release.

### sighup-distribution

11. **Distribution Update**: in the distribution repository, modify the `kfd.yaml` file pointing to the new RC tag and bump:

    ```yaml
    kubernetes:
    ..
    onpremises:
        version: X.Y.Z
        installer: vX.Y.Z-rc.0
    ..
    tools:
    ..
        kubectl:
            version: X.Y.Z
    ..
    ```

12. **Complete Testing**: use a `e2e-YYYYMMDD-{1,2,3,4,N}` tag to trigger all the e2e tests.

> [!NOTE]
> If tests fail or issues are found, fix the problems in the installer repository and repeat steps 10,11,12.

## CIS Kubernetes Benchmark

Whenever a new version of the CIS Kubernetes Benchmark (e.g. `cis-1.12`) is released, the compliance of the SIGHUP Distribution on-premises installer must be verified by means of [kube-bench](https://github.com/aquasecurity/kube-bench). This tool evaluates compliance by running a set of checks defined in a configuration corresponding to the specific platform it's executed on (see [kube-bench configs](https://github.com/aquasecurity/kube-bench/tree/main/cfg)).

We maintain our `customized configuration` under `utils/kube-bench`, which differs from the upstream rule set by skipping checks that are not applicable in our context. Every deviation from upstream must be documented, including a clear justification for the change.

To effectively maintain CIS compliance, follow the steps below:
1. **Monitor for CIS Benchmark and kube-bench updates**: Regularly check for new versions of the CIS Kubernetes Benchmark and the corresponding updates in the kube-bench rule sets.
2. **Compare upstream configs with our custom rule set**: When a new config version is released in the kube-bench repository, compare it against our current configuration. Identify any new, modified, or removed checks and determine the necessary updates to maintain compliance with the latest CIS version.
3. **Ensure full traceability for all skipped or modified checks**:
  - Avoid commenting out tests to exclude them; use explicit skip mechanisms instead.
  - When modifying a test, limit changes to the minimum necessary.
  - In all cases, provide a clear justification for the change, and ensure it is properly documented and tracked (refer to the [kube-bench configuration changelog](./utils/kube-bench/CHANGELOG.md))
4. **Test updated configurations**: Run the available kube-bench version using the updated configuration to validate the results. Ensure that there are no false positives, errors, or unexpected behavior introduced by the changes.
5. **Update documentation and changelogs**: Ensure that any updates made to the custom rule set are reflected in the documentation. Maintain a changelog with a commit history that explains what changed and why.