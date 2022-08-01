variable "image_source" {
  type    = string
  default = "alpine:latest"
}
variable "default_user" {
  type    = string
  default = "generic"
}
variable "default_uid" {
  type    = string
  default = "1000"
}
variable "docker_registry" {
  type = string
}
variable "container_name" {
  type    = string
  default = "base_image"
}
variable "build_type" {
  type    = string
  default = ""
}

variable "ghcr_password" {
  type    = string
  default = ""
  sensitive = true
}

locals {
  build_version = formatdate("YYYY.MM", timestamp())
}

source "docker" "container_image" {
  image  = "${var.image_source}"
  commit = true
  pull   = true
  changes = [
    "USER ${var.default_user}",
    "WORKDIR /",
    "ENTRYPOINT [\"tini\", \"-v\", \"--\", \"./start.sh\"]",
  ]
}
build {
  source "source.docker.container_image" {
    name = "latest"
  }

  // Base configuration and files for containers
  provisioner "file" {
    source      = "${path.root}/files/apt-requirements.txt"
    destination = "/etc/apt-requirements.txt"
  }

  provisioner "file" {
    source      = "${path.root}/files/pip-requirements.txt"
    destination = "/etc/pip-requirements.txt"
  }

  provisioner "file" {
    source      = "${path.root}/tests/tests.sh"
    destination = "/etc/tests.sh"
  }

  provisioner "file" {
    source      = "${path.root}/files/installer.sh"
    destination = "/installer.sh"
  }

  provisioner "file" {
    source      = "${path.root}/files/start.sh"
    destination = "/start.sh"
  }

  provisioner "shell" {
    inline = [
      "bash -c /installer.sh",
    ]
  }

  // Create container images with tags
  post-processors {
    post-processor "docker-tag" {
      repository = "${var.docker_registry}/${var.container_name}"
      tags = [
        "${local.build_version}",
        "latest"
      ]
    }
    // Push containers to gitlab container registry
    post-processor "docker-push" {
      login = true
      login_server = "ghcr.io"
      login_username = "johnsondnz"
      login_password = "${var.ghcr_password}"
    }
  }
}
