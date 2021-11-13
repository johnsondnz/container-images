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
    "WORKDIR /home/${var.default_user}/projects",
    "ENTRYPOINT [\"/bin/bash\", \"-c\"]",
    "CMD [\"pre-commit run --all-files\"]",
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

  // Minimal container for runners
  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update && apt install --no-install-recommends -yqq curl software-properties-common gnupg2",
      "apt update -yqq",
      "xargs -a /etc/apt-requirements.txt apt install -yqq",
      "[ -s /etc/pip-requirements.txt ] && echo '==> Install more pip packages' && pip3 install --no-cache-dir -r /etc/pip-requirements.txt || echo '==> No additional packages to install'",
      "groupadd ${var.default_user} --gid ${var.default_uid}",
      "useradd ${var.default_user} --uid ${var.default_uid} --gid ${var.default_uid} -m --shell /bin/bash",
      "echo 'export PATH=/home/${var.default_user}/.local/bin:$PATH' >> /home/${var.default_user}/.bashrc",
      "apt autoremove -yqq --purge",
      "apt autoclean",
      "rm -rf /var/lib/apt/lists/*",
      "rm /etc/pip-requirements.txt",
      "rm /etc/apt-requirements.txt"
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
