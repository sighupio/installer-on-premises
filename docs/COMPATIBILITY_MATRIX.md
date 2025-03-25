# Compatibility Matrix

| Module Version / Kubernetes Version |       1.32.3       |       1.31.7       |       1.31.4       |      1.30.11       |       1.30.6       |      1.29.10       |       1.29.3       |      1.28.15       |       1.28.7       |       1.27.6       |       1.26.7       |       1.26.3       |      1.25.12       |       1.25.6       |      1.24.16       |       1.24.7       |
| ----------------------------------- | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| v1.28.7                             |                    |                    |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.28.7-rev.1                       |                    |                    |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.29.3                             |                    |                    |                    |                    |                    |                    | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.29.3-rev.1                       |                    |                    |                    |                    |                    |                    | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.29.3-rev.2                       |                    |                    |                    |                    |                    |                    | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| v1.30.6                             |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| v1.31.4                             |                    |                    |     :warning:      |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| v1.31.4-rev.1                       |                    |                    | :white_check_mark: |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| v1.32.3                             | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |


All versions below v1.28.7 will not work due to the removal of the old package registry managed by google.

|        Icon        | Legend       |
| :----------------: | ------------ |
| :white_check_mark: | Compatible   |
|     :warning:      | Has issues   |
|        :x:         | Incompatible |

## Warnings

- v1.31.4 has a known issue that affects the upgrade process, please use v1.31.4-rev.1 instead. See issue [#115](https://github.com/sighupio/fury-kubernetes-on-premises/issues/115) for more information.
