output "network_id" {
  description = "Идентификатор созданной сети"
  value       = yandex_vpc_network.platform.id
}

output "subnet_id" {
  description = "Идентификатор созданной подсети"
  value       = yandex_vpc_subnet.platform.id
}

output "instance_id" {
  description = "Идентификатор ВМ"
  value       = yandex_compute_instance.application.id
}

output "internal_ip" {
  description = "Внутренний IP ВМ"
  value       = yandex_compute_instance.application.network_interface[0].ip_address
}

output "external_ip" {
  description = "Публичный IP ВМ"
  value       = try(yandex_compute_instance.application.network_interface[0].nat_ip_address, null)
}
