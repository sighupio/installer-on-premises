### Summary 💡

Update the on-premises roles for compatibility with recent `ansible-core` releases.
SIGHUP Distribution pins `ansible-core 2.21.0` and its required collections in
[`kfd.yaml`](https://github.com/sighupio/distribution/blob/main/kfd.yaml#L60-L69), exposing these deprecations during on-premises installations.

Closes: https://github.com/sighupio/product-management/issues/677

### Description 📝

- Replace injected top-level facts with `ansible_facts`.
- Replace deprecated APT modules with `deb822_repository`.
- Preserve repository overrides and clean up legacy APT sources.

### Breaking Changes 💔

None.

### Tests performed 🧪

- [x] Syntax-checked the playbooks with `ansible-core 2.21.0`.
- [x] Tested the containerd, load balancer, and cluster playbooks.

### Future work 🔧

None.

### Self-assessment checklist 🏁

- [x] My PR has a clear scope and does not mix together several unrelated changes
- [ ] I've updated the `docs/releases/unreleased.md` file (or equivalent)
- [x] I've tested the proposed changes and wrote the tests performed in the section above
- [ ] My branch is up-to-date with the target branch and there are no conflicts
- [x] I've considered all the different cluster kinds (KFDDistribution, OnPremises, EKSCluster, Immutable) that may be affected by this change
- [ ] CI is green
