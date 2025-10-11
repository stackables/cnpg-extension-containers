variable "REGISTRY" {
  default = "ghcr.io"
}

variable "PG_VERSION" {
  default = "18"
}

variable "PLV8_VERSION" {
  default = "3.2.4"
}

variable "DISTRO" {
  default = "trixie"
}

target "build" {
  dockerfile = "./Dockerfile"
  tags = [
    "${REGISTRY}/plv8:${PG_VERSION}-${PLV8_VERSION}-${formatdate("YYYYMMDDHHMM", timestamp())}-${DISTRO}",
    "${REGISTRY}/plv8:${PG_VERSION}-${PLV8_VERSION}-${DISTRO}",
  ]
  platforms = ["linux/amd64", "linux/arm64"]
}

