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
| plv8       | 3.2.5   | amd64, arm64 | trixie  |
| wal2json   | 2.6     | amd64, arm64 | trixie  |
| pgmq       | 1.13.1  | amd64, arm64 | trixie  |
| pg_cron    | 1.6.8   | amd64, arm64 | trixie  |

The plv8 image also ships each older version's library name (`plv8-3.2.4.so`, …) as a relative link to the current library, so a database created with an older plv8 can run `ALTER EXTENSION plv8 UPDATE`.

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
          reference: ghcr.io/stackables/plv8:18-3.2.5-trixie
      - name: wal2json
        image:
          reference: ghcr.io/stackables/wal2json:18-2.6-trixie
      - name: pgmq
        image:
          reference: ghcr.io/stackables/pgmq:18-1.13.1-trixie
      - name: pg_cron
        image:
          reference: ghcr.io/stackables/pg_cron:18-1.6.8-trixie
storage:
    size: 1Gi
```

To test just the extensions without the ImageVolume, use the bundled test image (PostgreSQL 18.6, embeds the extensions above), tagged `ghcr.io/stackables/postgres:18.6-standard-trixie`

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-with-plv8
spec:
  instances: 1
  imageName: ghcr.io/stackables/postgres:18.6-standard-trixie
  storage:
    size: 1Gi
```

