terraform {
  required_version = ">= 1.5.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.130"
    }
  }
}

provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

data "yandex_compute_image" "boot" {
  family = var.image_family
}

resource "yandex_vpc_network" "platform" {
  name   = "future20-${var.environment}-network"
  labels = local.labels
}

resource "yandex_vpc_subnet" "platform" {
  name           = "future20-${var.environment}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.platform.id
  v4_cidr_blocks = [var.subnet_cidr]
}

resource "yandex_compute_disk" "boot" {
  name     = "future20-${var.environment}-boot"
  zone     = var.zone
  type     = var.disk_type
  size     = var.disk_size
  image_id = var.image_id != null ? var.image_id : data.yandex_compute_image.boot.id
  labels   = local.labels
}

resource "yandex_compute_instance" "application" {
  name        = "future20-${var.environment}-app"
  zone        = var.zone
  platform_id = "standard-v3"
  labels      = local.labels

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.platform.id
    nat       = var.enable_nat
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

locals {
  labels = {
    project     = "future-2-0"
    environment = var.environment
    managed_by  = "terraform"
  }
}
