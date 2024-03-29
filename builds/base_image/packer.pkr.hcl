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
    "WORKDIR /home/${var.default_user}",
    "ENTRYPOINT [\"/bin/bash\", \"-c\"]",
    "CMD [\"/bin/bash\"]",
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
    source      = "${path.root}/files/init.sh"
    destination = "/init.sh"
  }

  provisioner "file" {
    source      = "${path.root}/files/installer.sh"
    destination = "/installer.sh"
  }

  provisioner "shell" {
    inline = [
      "groupadd ${var.default_user} --gid ${var.default_uid}",
      "useradd ${var.default_user} --uid ${var.default_uid} --gid ${var.default_uid} -m --shell /bin/bash",
      "bash -c /installer.sh"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/files/.zshrc"
    destination = "/home/${var.default_user}/.zshrc"
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
    // Test required packages are available 
    post-processor "shell-local" {
      inline = ["docker run --rm ${var.docker_registry}/${var.container_name}:latest /etc/tests.sh"]
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
