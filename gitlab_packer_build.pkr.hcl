packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "gitlab-url" {
  type = string
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "gitlab" {
  ami_name      = "gitlab-debian-${local.timestamp}"
  instance_type = "t2.medium"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "debian-11-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "admin"

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = true
  }
}

build {
  name = "gitlab-debian"
  sources = [
    "source.amazon-ebs.gitlab"
  ]

  provisioner "shell" {
    inline = [
      "echo Checking for updates",
      "sudo apt-get update",
    ]
  }

  provisioner "ansible" {
    playbook_file = "./provisioners/ansible/playbook.yml"
    user          = "admin"
    ansible_ssh_extra_args = [
      "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
    ]
    extra_arguments = ["--extra-vars", "gitlab_url=${var.gitlab-url}"]
  }
}
