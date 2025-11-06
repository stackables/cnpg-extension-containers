# CNPG PostgreSQL Extensions Container Images

> [!WARNING]
> For the impatient ones who can’t wait for the official [`image volume extensions`](https://cloudnative-pg.io/documentation/current/imagevolume_extensions/) builds 😅  
>
> The images below are provided for **testing and experimentation only**, until official builds are released.


This repository provides **maintenance scripts** for building **immutable
container images** containing PostgreSQL extensions supported by
[CloudNativePG](https://cloudnative-pg.io/). These images are designed to
integrate seamlessly with the [`image volume extensions` feature](https://cloudnative-pg.io/documentation/current/imagevolume_extensions/)
in CloudNativePG.

---

## Requirements

- **CloudNativePG** ≥ 1.27
- **PostgreSQL** ≥ 18 (requires the `extension_control_path` feature)
- **Kubernetes** 1.33+ with [ImageVolume feature enabled](https://kubernetes.io/blog/2024/08/16/kubernetes-1-31-image-volume-source/)

---

## Supported Extensions

We support only postgres 18 images on trixie. Images below are experimental and intended for testing, not production deployments.

| Extension  | Version | Platforms    | Distros |
|------------|---------|--------------|---------|
| plv8v      | 3.2.4   | amd64, arm64 | trixie  |
| wal2json   | 2.6     | amd64, arm64 | trixie  |
| pgmq       | 1.7.0   | amd64, arm64 | trixie  |

## Usage

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-with-plv8
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql:18-trixie
  postgresql:
    extensions:
      - name: plv8
        image:
          reference: ghcr.io/stackables/plv8:18-3.2.4-trixie
      - name: wal2json
        image:
          reference: ghcr.io/stackables/wal2json:18-2.6-trixie
      - name: pgmq
        image:
          reference: ghcr.io/stackables/pgmq:18-1.7.0-trixie
storage:
    size: 1Gi
```

To test just the extensions without the ImageVolume (embeds the extensions above)

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-with-plv8
spec:
  instances: 1
  imageName: ghcr.io/stackables/postgres:18-standard-trixie
  storage:
    size: 1Gi
```

