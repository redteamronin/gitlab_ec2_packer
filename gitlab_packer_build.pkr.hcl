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
  ami_name      = "gitlab-ubuntu-${local.timestamp}"
  instance_type = "t2.medium"
  region        = "${var.region}"
  #source_ami    = "ami-0f35413f664528e13"
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
    #device_name           = "/dev/sda1"
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
  # Provisioner blocks are executed in order
  provisioner "shell" {
    inline = [
      "echo Checking for updates",
      "sudo apt-get update",
    ]
  }

  #provisioner "shell" {
  #  script          = "gitlab.sh"
  #  execute_command = "{{.Vars}} bash '{{.Path}}'"
  #}

  provisioner "ansible" {
    playbook_file = "./provisioners/ansible/playbook.yml"
    user          = "admin"
    ansible_ssh_extra_args = [
      "-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa"
    ]
    extra_arguments = ["--extra-vars", "gitlab_url=${var.gitlab-url}"]
  }
}
