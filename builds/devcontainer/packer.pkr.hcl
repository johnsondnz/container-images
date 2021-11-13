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
    "USER ${var.default_user}"
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

  provisioner "shell" {
    inline = [
      "bash -c /installer.sh",
      "echo 'export GPG_TTY=\"$(tty)\"' >> /home/${var.default_user}/.bashrc",
      "mkdir /home/${var.default_user}/.gnupg",
      "chown -R ${var.default_user} /home/${var.default_user}/.gnupg",
      "echo ${var.default_user} ALL=\"(root)\" NOPASSWD:ALL > /etc/sudoers.d/${var.default_user}",
      "chmod 0440 /etc/sudoers.d/${var.default_user}",
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
    // Test required packages are available 
    post-processor "shell-local" {
      inline = ["docker run --rm ${var.docker_registry}/${var.container_name}:latest /etc/tests.sh"]
    }
    // Push containers to gitlab container registry
    post-processor "docker-push" {}
  }
}
