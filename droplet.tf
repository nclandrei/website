variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}
variable "user" {}

# Set digitalocean as provider
provider "digitalocean" {
	token = "${var.do_token}"
}

# Create droplet for website
resource "digitalocean_droplet" "nclandrei" {
	image  = "ubuntu-16-04-x64"
	name   = "website"
	region = "eu-west-2"
	size   = "512mb"
	private_networking = true
	ssh_keys = [
		"${var.ssh_fingerprint}"
	]

	provisioner "remote-exec" {
		inline = [
			"echo installing core packages",
			"rm /etc/motd # it does not spark joy",
			"echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_9.0/ /' > /etc/apt/sources.list.d/fish.list",
			"wget -nv https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key -O Release.key >>/root/provisioning.log 2>&1",
			"apt-key add - < Release.key >>/root/provisioning.log 2>&1",
			"apt-get update >>/root/provisioning.log 2>&1",
			"apt-get install -y --force-yes sudo make vim git mercurial mosh fish curl wget unzip htop jq binutils gcc libpcap-dev >>/root/provisioning.log 2>&1",

			"echo installing Go",
			"wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz >>/root/provisioning.log 2>&1",
			"tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz >>/root/provisioning.log 2>&1",
			"rm go1.9.2.linux-amd64.tar.gz",
			
			"echo setting up user ${var.user}",
			"sed -i.bak 's/sudo\tALL=(ALL:ALL) ALL/sudo\tALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers",
			"adduser --shell /usr/bin/fish --ingroup sudo --disabled-password --gecos '' ${var.user} >>/root/provisioning.log 2>&1",
			"mkdir -p /home/${var.user}/.ssh",
			"chown -R ${var.user}:sudo /home/${var.user}/.ssh",
		]
	}

	connection {
    	user = "root"
    	type = "ssh"
    	private_key = "${file(var.pvt_key)}"
    	timeout = "2m"
  }
}

# Configure domain name on droplet
resource "digitalocean_domain" "default" {
	name = "nclandrei.com"
	ip = "${digitalocean_droplet.nclandrei.ipv4_address}"
}

# Redirect www.nclandrei.com to nclandrei.com
resource "digitalocean_record" "CNAME-www" {
  domain = "${digitalocean_domain.default.name}"
  type = "CNAME"
  name = "www"
  value = "@"
}


