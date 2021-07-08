#!/bin/bash
# Name: ubuntu-config-vault-ssh-helper.sh
# Owner: Saurav Mitra
# Description: Configure vault-ssh-helper in remote Ubuntu servers

sudo apt-get -y update
sudo apt-get -y install python3-pip unzip
sudo yes | pip3 install awscli

# Install vault-ssh-helper
curl -o /tmp/vault-ssh-helper_0.2.1_linux_amd64.zip https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip
sudo unzip -o /tmp/vault-ssh-helper_0.2.1_linux_amd64.zip -d /usr/local/bin
sudo chown -R root:root /usr/local/bin/vault-ssh-helper
sudo chmod 0755 /usr/local/bin/vault-ssh-helper

# Configure vault-ssh-helper
sudo mkdir /etc/vault-ssh-helper.d/
export s3_bucket_name=vault-ssl-certs
aws s3 cp s3://${s3_bucket_name}/ca.cert /etc/vault-ssh-helper.d/ca.cert
# Update CA Certs
sudo cp /etc/vault-ssh-helper.d/ca.cert /usr/local/share/ca-certificates/ca.cert
sudo update-ca-certificates
# Update Hosts file
sudo tee -a /etc/hosts <<EOF
10.0.1.91   dc1-vault1.local  
10.0.1.92   dc1-vault2.local
10.0.1.93   dc1-vault3.local
EOF

export VAULT_EXTERNAL_ADDR=https://dc1-vault1.local:8200
sudo tee /etc/vault-ssh-helper.d/config.hcl <<EOF
vault_addr = "$VAULT_EXTERNAL_ADDR"
ssh_mount_point = "ssh"
namespace = "root"
ca_cert = "/etc/vault-ssh-helper.d/ca.cert"
tls_skip_verify = false
allowed_roles = "otp_key_role"
EOF

# Setup PAM SSHD
sudo cp /etc/pam.d/sshd /etc/pam.d/sshd.orig
sed -i "s|^@include common-auth$|#@include common-auth|" /etc/pam.d/sshd
sudo tee -a /etc/pam.d/sshd <<EOF
auth requisite pam_exec.so quiet expose_authtok log=/var/log/vaultssh.log /usr/local/bin/vault-ssh-helper -config=/etc/vault-ssh-helper.d/config.hcl
auth optional pam_unix.so not_set_pass use_first_pass nodelay
EOF

# Setup SSHD Config
sed -i "s|^ChallengeResponseAuthentication no$|ChallengeResponseAuthentication yes|" /etc/ssh/sshd_config

sudo systemctl restart sshd
# Verify the configuration
vault-ssh-helper -verify-only -config /etc/vault-ssh-helper.d/config.hcl
