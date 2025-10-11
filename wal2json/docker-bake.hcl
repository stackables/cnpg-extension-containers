variable "REGISTRY" {
  default = "ghcr.io"
}

variable "PG_VERSION" {
  default = "18"
}

variable "WAL2JSON_VERSION" {
  default = "2.6"
}

variable "DISTRO" {
  default = "trixie"
}

target "build" {
  dockerfile = "./Dockerfile"
  tags = [
    "${REGISTRY}/wal2json:${PG_VERSION}-${WAL2JSON_VERSION}-${formatdate("YYYYMMDDHHMM", timestamp())}-${DISTRO}",
    "${REGISTRY}/wal2json:${PG_VERSION}-${WAL2JSON_VERSION}-${DISTRO}",
  ]
}

