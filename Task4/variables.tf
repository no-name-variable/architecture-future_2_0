variable "cloud_id" {
  description = "Идентификатор облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "Идентификатор каталога Yandex Cloud"
  type        = string
}

variable "zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}

variable "environment" {
  description = "Имя окружения"
  type        = string
  default     = "dev"
}

variable "subnet_cidr" {
  description = "CIDR подсети"
  type        = string
  default     = "10.20.0.0/24"
}

variable "image_id" {
  description = "Идентификатор загрузочного образа; null выбирает последний образ семейства image_family"
  type        = string
  default     = null
  nullable    = true
}

variable "image_family" {
  description = "Семейство публичного образа для автоматического выбора"
  type        = string
  default     = "ubuntu-2204-lts"
}

variable "cores" {
  description = "Число vCPU"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Объём RAM в ГБ"
  type        = number
  default     = 4
}

variable "core_fraction" {
  description = "Гарантированная доля vCPU в процентах"
  type        = number
  default     = 100
}

variable "disk_size" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 30
}

variable "disk_type" {
  description = "Тип диска"
  type        = string
  default     = "network-ssd"
}

variable "enable_nat" {
  description = "Выдать ВМ публичный IP для учебного стенда"
  type        = bool
  default     = true
}

variable "ssh_user" {
  description = "Пользователь для SSH"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Публичный SSH-ключ без приватной части"
  type        = string
  sensitive   = true
}
