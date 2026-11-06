FROM postgres:18.6-trixie AS builder

ENV PLV8_BRANCH=r3.2
ENV PLV8_VERSION=3.2.5
ENV PG_MAJOR=18

ARG BIGINT_GRACEFUL_VALUE='BIGINT_GRACEFUL=1'
ARG BIGINT_GRACEFUL
ARG BIGINT_GRACEFUL_FLAG=${BIGINT_GRACEFUL:+$BIGINT_GRACEFUL_VALUE}

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
  && git clone --branch ${PLV8_BRANCH} --single-branch --depth 1 https://github.com/plv8/plv8 \
  && cd plv8 \
  && git submodule update --init \
  && cd deps/v8-cmake \
  && git checkout master \
  && cd ../.. \
  && make ${BIGINT_GRACEFUL_FLAG} \
  && strip plv8-${PLV8_VERSION}.so \
  && make install

# Older versions' library names, as relative links to the new library, for
# databases created before this version. Made here because scratch has no shell,
# and in a directory of their own so COPY keeps them links.
COPY compat-links.sh /usr/local/bin/compat-links.sh
RUN compat-links.sh make /usr/share/postgresql/${PG_MAJOR}/extension ${PLV8_VERSION} /out/lib \
  && mkdir -p /tmp/final-lib \
  && cp -a /usr/lib/postgresql/${PG_MAJOR}/lib/plv8* /out/lib/. /tmp/final-lib/ \
  && compat-links.sh check /tmp/final-lib /usr/share/postgresql/${PG_MAJOR}/extension ${PLV8_VERSION}

FROM scratch

ENV PLV8_VERSION=3.2.5
ENV PG_MAJOR=18

COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/plv8* /share/extension/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/plv8* /lib/
COPY --from=builder /out/lib/ /lib/
COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/bitcode/plv8-${PLV8_VERSION}/* /lib/bitcode/plv8-${PLV8_VERSION}/

