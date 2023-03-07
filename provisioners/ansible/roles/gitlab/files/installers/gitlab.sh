#!/usr/bin/bash -x

sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates perl
# If you fancy email, install postfix
#sudo apt-get install -y postfix
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="$1" apt-get install gitlab-ce
