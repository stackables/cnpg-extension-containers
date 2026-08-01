variable "REGISTRY" {
  default = "ghcr.io"
}

variable "PG_VERSION" {
  default = "18"
}

variable "PG_CRON_VERSION" {
  default = "1.6.7"
}

variable "DISTRO" {
  default = "trixie"
}

target "build" {
  dockerfile = "./Dockerfile"
  tags = [
    "${REGISTRY}/pg_cron:${PG_VERSION}-${PG_CRON_VERSION}-${formatdate("YYYYMMDDHHMM", timestamp())}-${DISTRO}",
    "${REGISTRY}/pg_cron:${PG_VERSION}-${PG_CRON_VERSION}-${DISTRO}",
  ]
  platforms = ["linux/amd64", "linux/arm64"]
}
