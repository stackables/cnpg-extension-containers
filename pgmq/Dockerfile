FROM postgres:18.0-trixie AS builder

ENV PGMQ_VERSION=1.7.0
ENV PGMQ_TAG='v1.7.0'
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
  && git clone --branch ${PGMQ_TAG} --single-branch --depth 1 https://github.com/pgmq/pgmq \
  && cd pgmq/pgmq-extension \
  && make \
  && make install

FROM scratch

ENV PG_MAJOR=18

COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/pgmq* /share/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/pgmq* /lib/

