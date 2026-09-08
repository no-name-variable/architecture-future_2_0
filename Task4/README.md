# Task 4. Облачная инфраструктура с Terraform

- `main.tf` — VPC Network, Subnet, Boot Disk и Compute VM.
- `variables.tf` — входные параметры без секретов.
- `outputs.tf` — идентификаторы ресурсов и IP-адреса ВМ.
- `terraform.tfvars` — демонстрационные значения, которые нужно заменить перед запуском.
- `diagram.svg` и `diagram.png` — схема Terraform-managed и ручных компонентов.
- `justification.md` — выбор параметров и роль Infrastructure as Code.

Для фактического `apply` нужны действующие идентификаторы Yandex Cloud, публичный
SSH-ключ и `YC_TOKEN`; они не сохраняются в репозитории.

После успешного `terraform apply` добавьте в этот каталог `apply-result.png` —
скриншот терминала с итогом применения и без секретов.
