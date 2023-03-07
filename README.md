# Create Gitlab AMI from Debian 11 AMI:</br>
`packer build -var "gitlab-url=<subdomain>.<domain>" gitlab_packer_build.pkr.hcl`</br>
This gives you an AMI ready to go to use Terraform - https://github.com/redteamronin/gitlab_terraform_build
