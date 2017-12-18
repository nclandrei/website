variable "do_token" {}
variable "pub_key" {}
variable "pvt_key" {}
variable "ssh_fingerprint" {}

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
}

resource "digitalocean_domain" "default" {
	name = "nclandrei.com"
	ip = {}
}

connection {
      user = "root"
      type = "ssh"
      private_key = "${file(var.pvt_key)}"
      timeout = "2m"
  }
