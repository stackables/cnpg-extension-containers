variable "REGISTRY" {
  default = "ghcr.io"
}

variable "PG_VERSION" {
  default = "18.4"
}

variable "DISTRO" {
  default = "standard-trixie"
}

target "build" {
  dockerfile = "./Dockerfile"
  tags = [
    "${REGISTRY}/postgres:${PG_VERSION}-${formatdate("YYYYMMDDHHMM", timestamp())}-${DISTRO}",
    "${REGISTRY}/postgres:${PG_VERSION}-${DISTRO}",
    "${REGISTRY}/postgres:18-${DISTRO}",
  ]
  platforms = ["linux/amd64", "linux/arm64"]
}

