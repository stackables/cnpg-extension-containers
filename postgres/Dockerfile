FROM ghcr.io/stackables/plv8:18-3.2.4-trixie AS builder-plv8

FROM ghcr.io/stackables/wal2json:18-2.6-trixie AS builder-wal2json

FROM ghcr.io/cloudnative-pg/postgresql:18.0-standard-trixie

ENV PG_MAJOR=18

COPY --from=builder-wal2json /usr/lib/postgresql/${PG_MAJOR}/lib/wal2json* /usr/lib/postgresql/${PG_MAJOR}/lib/

COPY --from=builder-plv8 /usr/share/postgresql/${PG_MAJOR}/extension/plv8* /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=builder-plv8 /usr/lib/postgresql/${PG_MAJOR}/lib/plv8* /usr/lib/postgresql/${PG_MAJOR}/lib/
COPY --from=builder-plv8 /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/plv8* /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/

