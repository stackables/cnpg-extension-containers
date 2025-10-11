FROM postgres:18.0-trixie AS builder

ENV WAL2JSON_BRANCH=wal2json_2_6
ENV PG_MAJOR=18

RUN buildDependencies="build-essential \
    ca-certificates \
    curl \
    git-core \
    postgresql-server-dev-${PG_MAJOR} \
    pkg-config \
    clang \
    binutils \
    libstdc++-12-dev \
    cmake" \
    && apt-get update && apt-get install -y --no-install-recommends ${buildDependencies}
	
RUN mkdir -p /tmp/build \
  && cd /tmp/build \
  && git clone --branch ${WAL2JSON_BRANCH} --single-branch --depth 1 https://github.com/eulerto/wal2json \
  && cd wal2json \
  && make \
  && make install

FROM scratch

ENV PG_MAJOR=18

COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/wal2json.so /lib/

