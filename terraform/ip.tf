data "http" "ip_address" {
    url = var.public_api
}

locals {
    my_ip_address = "${data.http.ip_address}/32"
}
