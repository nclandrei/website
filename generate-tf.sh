#!/bin/sh

default_digitalocean_token=$(head -n 1 $HOME/.digitalocean/tf-token.txt)
read -p "DigitalOcean token [${default_digitalocean_token}]: " do_token
do_token=${do_token:-$default_digitalocean_token}
if [ -z "$do_token" ]
then
	echo "token is required"
	exit 1
fi

default_private_key_file="$HOME/.ssh/id_rsa"
read -p "Path to your SSH key [${default_private_key_file}]: " private_key_file
private_key_file=${private_key_file:-$default_private_key_file}
if [ ! -f $private_key_file ]
then
	echo "$private_key_file not found"
	exit 1
fi

default_public_key_file="${private_key_file}.pub"
read -p "Path to your public SSH key [${default_public_key_file}]: " public_key_file
public_key_file=${public_key_file:-$default_public_key_file}
if [ ! -f $public_key_file ]
then
	echo "$public_key_file not found"
	exit 1
fi

ssh_fingerprint=$(ssh-keygen -E md5 -lf $public_key_file | awk '{print $2}' | cut -d':' -f2-)
vars_file="terraform.tfvars"
authorized_keysfile="authorized_keys"

cat >$vars_file <<EOF
do_token             = "$do_token"
ssh_fingerprint      = "$ssh_fingerprint"
EOF

echo "All done."