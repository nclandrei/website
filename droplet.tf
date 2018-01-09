variable "do_token" 			{}
variable "ssh_fingerprint" 		{}
variable "user" 				{}
variable "hostname" 			{}
variable "region"               {}
variable "size"					{}
variable "pvt_key"				{}

# Set digitalocean as provider
provider "digitalocean" {
	token = "${var.do_token}"
}

# Create droplet for website
resource "digitalocean_droplet" "nclandrei" {
	image  = "ubuntu-16-04-x64"
	name     = "${var.hostname}"
	region   = "${var.region}"
	size     = "${var.size}"
	ssh_keys = ["${var.ssh_fingerprint}"]

	provisioner "remote-exec" {
		inline = [
			"echo installing core packages",
			"rm /etc/motd # it does not spark joy",
			"echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/2/Debian_9.0/ /' > /etc/apt/sources.list.d/fish.list",
			"wget -nv https://download.opensuse.org/repositories/shells:fish:release:2/Debian_9.0/Release.key -O Release.key >>/root/provisioning.log 2>&1",
			"apt-key add - < Release.key >>/root/provisioning.log 2>&1",
			"apt-get update >>/root/provisioning.log 2>&1",
			"apt-get install -y --force-yes sudo make vim git mosh fish curl wget unzip htop jq binutils gcc libpcap-dev >>/root/provisioning.log 2>&1",

			"echo installing Go",
			"apt-get --assume-yes golang-go",

			"echo setting up user ${var.user}",
			"sed -i.bak 's/sudo\tALL=(ALL:ALL) ALL/sudo\tALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers",
			"adduser --shell /usr/bin/fish --ingroup sudo --disabled-password --gecos '' ${var.user} >>/root/provisioning.log 2>&1",
			"mkdir -p /home/${var.user}/.ssh",
			"chown -R ${var.user}:sudo /home/${var.user}/.ssh",

			"echo setting up Go",
			"set -x GOPATH $HOME",

			"echo setting up Hugo",
			"wget https://github.com/gohugoio/hugo/releases/download/v0.32.3/hugo_0.32.3_Linux-64bit.deb",
			"dpkg -i hugo*.deb",
			"rm hugo*",

			"echo running server",
			"go get -u github.com/nclandrei/nclandrei.com",
			"go run $GOPATH/src/github.com/nclandrei/nclandrei.com"
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
	ip_address = "${digitalocean_droplet.nclandrei.ipv4_address}"
}

# Redirect www.nclandrei.com to nclandrei.com
resource "digitalocean_record" "CNAME-www" {
  domain = "${digitalocean_domain.default.name}"
  type = "CNAME"
  name = "www"
  value = "@"
}

output "hostname" {
	value = "${var.hostname}"
}

output "ip" {
	value = "${digitalocean_droplet.nclandrei.ipv4_address}"
}