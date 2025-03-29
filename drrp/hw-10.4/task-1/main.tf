terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "default" {}

resource "yandex_vpc_subnet" "default" {
  name           = "default-subnet"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "vm" {
  count       = 2
  name        = "vm-${count.index}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd86601pa1f50ta9dffg" # ID образа Debian или Ubuntu
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      package_update: true
      package_upgrade: true
      packages:
        - nginx
      runcmd:
        - systemctl enable --now nginx
    EOF
  }
}

resource "yandex_lb_target_group" "tg" {
  name = "target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.vm[*]
    content {
      address   = target.value.network_interface[0].ip_address
      subnet_id = yandex_vpc_subnet.default.id
    }
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "load-balancer"

  listener {
    name     = "http"
    port     = 80
    protocol = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

output "load_balancer_ip" {
  value = try([for l in yandex_lb_network_load_balancer.nlb.listener : l.external_address_spec[0].address][0], "No IP yet")
}
