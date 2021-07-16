#!/bin/bash
# Name: test-webapp-ssl.sh
# Owner: Saurav Mitra
# Description: Configure the webapp server (UBUNTU) with SSL

sudo hostnamectl set-hostname "webapp.demo.com"
sudo apt-get --assume-yes --quiet  update              >> /dev/null
sudo apt-get --assume-yes --quiet install nginx        >> /dev/null

# Add SSL Cert & Key
# server-intermediate-ca certs chain order
/etc/ssl/certs/webapp-chain.cert
/etc/ssl/private/webapp.key

# Update CA Certs
# /etc/pki/ca-trust/source/anchors/ca.cert
# sudo update-ca-trust

sudo tee /etc/nginx/sites-available/default <<EOF
server {
	listen              443 ssl;
	server_name         webapp.demo.com;
	ssl_certificate     /etc/ssl/certs/webapp-chain.cert;
	ssl_certificate_key /etc/ssl/private/webapp.key;
	root /var/www/html;
	index index.html index.htm index.nginx-debian.html;
	server_name _;
	location / {
		try_files \$uri \$uri/ =404;
	}
}

server {
	listen 80;
	listen [::]:80;
	server_name webapp.demo.com;
    return 302 https://\$server_name$request_uri;
	root /var/www/example.com;
}
EOF


/etc/init.d/nginx reload
/etc/init.d/nginx restart
