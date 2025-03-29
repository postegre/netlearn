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
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}

resource "yandex_compute_instance_group" "web_group" {
  name               = "nginx-group"
  folder_id          = var.yc_folder_id
  service_account_id = var.yc_sa_id
  depends_on         = [yandex_vpc_subnet.default]

  instance_template {
    platform_id = "standard-v1"

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
      }
    }

    network_interface {
      network_id = yandex_vpc_network.default.id
      subnet_ids = [yandex_vpc_subnet.default.id]
      nat        = true
    }

    metadata = {
      user-data = file("nginx-init.yaml")
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

  load_balancer {
    target_group_name = "nginx-target-group"
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nginx-lb"

  listener {
    name     = "http"
    port     = 80
    protocol = "tcp"
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.web_group.load_balancer[0].target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
  folder_id = "standard-images"
}

output "load_balancer_ip" {
  value = try([for l in yandex_lb_network_load_balancer.nlb.listener : l.external_address_spec[0].address][0], "No IP yet")
}
