variable "REGISTRY" {
  default = "ghcr.io"
}

variable "PG_VERSION" {
  default = "18"
}

variable "PGMQ_VERSION" {
  default = "1.7.0"
}

variable "DISTRO" {
  default = "trixie"
}

target "build" {
  dockerfile = "./Dockerfile"
  tags = [
    "${REGISTRY}/pgmq:${PG_VERSION}-${PGMQ_VERSION}-${formatdate("YYYYMMDDHHMM", timestamp())}-${DISTRO}",
    "${REGISTRY}/pgmq:${PG_VERSION}-${PGMQ_VERSION}-${DISTRO}",
  ]
  platforms = ["linux/amd64", "linux/arm64"]
}

