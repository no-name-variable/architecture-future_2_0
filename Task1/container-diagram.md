# Task 1. Целевая архитектура «Будущее 2.0» через год — C4-модель

Целевое состояние: слабосвязанная событийная платформа. Домены взаимодействуют через
события (Kafka) и реактивные потоки. Legacy DWH (SQL Server) и шина Camel остаются только
как «мосты совместимости» с антикоррупционными слоями (ACL) на время миграции. Аналитика
строится по модели Data Mesh поверх Data Lakehouse, доступ для бизнеса — через портал
самообслуживания (Self-service BI). Медкарты, истории болезни и снимки в аналитическую
витрину не попадают.

## Уровень 1 — Context

```mermaid
C4Context
  title Контекст: платформа данных «Будущее 2.0»

  Person(operator, "Оператор клиники", "Ведёт приём, медданные")
  Person(analyst, "Бизнес-аналитик / сотрудник домена", "Строит отчёты в рамках своего доступа")
  Person(dpo, "Data Product Owner / Governance", "Стандарты, политики, каталог")

  System_Boundary(f20, "Будущее 2.0") {
    System(platform, "Событийная платформа данных", "Kafka, Data Mesh, Lakehouse, Self-service BI")
    System(legacy, "Legacy DWH + ESB Camel", "Мост совместимости на время миграции")
  }

  System_Ext(reg, "Регуляторы", "152-ФЗ, мед/фин требования")
  System_Ext(partners, "Партнёры", "Фарма, производитель электроники, новые регионы")

  Rel(operator, platform, "Вводит операционные данные")
  Rel(analyst, platform, "Отчёты, конструктор витрин")
  Rel(dpo, platform, "Управляет каталогом и политиками")
  Rel(platform, legacy, "CDC / ACL", "постепенный вывод")
  Rel(partners, platform, "События/интеграции")
  Rel(platform, reg, "Соответствие требованиям")
```

## Уровень 2 — Container

```mermaid
C4Container
  title Контейнеры целевой платформы

  Person(analyst, "Сотрудник домена")
  Person(operator, "Оператор клиники")

  System_Boundary(f20, "Будущее 2.0") {
    Container(portal, "Портал самообслуживания (Self-service BI)", "Web", "Поиск данных, конструктор отчётов, RBAC")
    Container(catalog, "Data Catalog / Governance", "DataHub", "Метаданные, lineage, контракты, схемы, доступ")
    ContainerQueue(bus, "Событийная шина", "Apache Kafka", "Домены публикуют/подписываются на события, DLQ, Schema Registry")

    Container_Boundary(med, "Домен: Медицина (операционный)") {
      Container(medsvc, "Мед-сервисы", "Java/Go", "Пациентский поток (без аналитики по медкартам)")
    }
    Container_Boundary(fin, "Домен: Финтех/Банк") {
      Container(finsvc, "Финтех-сервисы", "Go/Java", "Счета, кредиты, платежи")
    }
    Container_Boundary(ai, "Домен: ИИ-сервисы") {
      Container(aisvc, "ИИ-сервисы", "Python", "Обработка медданных, инференс")
    }
    Container_Boundary(ops, "Домен: Операции (HR, инвентаризация, финотчётность)") {
      Container(opssvc, "Операционные сервисы", "—", "Управление клиниками, персонал, склад")
    }

    Container_Boundary(lake, "Аналитическая платформа (Data Mesh)") {
      ContainerDb(storage, "Объектное хранилище", "S3 / MinIO", "Сырые и обработанные данные доменов")
      Container(table, "Табличный формат", "Apache Iceberg + Nessie", "ACID, версии, схема")
      Container(query, "Движок запросов", "Dremio/Trino", "SQL поверх Lakehouse")
    }

    Container_Boundary(legacy, "Мост совместимости") {
      ContainerDb(dwh, "Legacy DWH", "SQL Server 2008", "Выводится из эксплуатации")
      Container(esb, "ESB", "Apache Camel", "Старые точечные интеграции")
      Container(acl, "ACL / CDC", "Debezium", "Изоляция и захват изменений")
    }
  }

  Rel(operator, medsvc, "Операционный ввод")
  Rel(analyst, portal, "Отчёты в рамках доступа")
  Rel(portal, query, "SQL-запросы к продуктам данных")
  Rel(portal, catalog, "Поиск данных и доступ")

  Rel(medsvc, bus, "События", "напр. Зарегистрирован пациент")
  Rel(finsvc, bus, "События", "Создан кредитный договор")
  Rel(aisvc, bus, "События", "Пройдено исследование ИИ")
  Rel(opssvc, bus, "События")

  Rel(bus, storage, "Потоковая загрузка в домены данных")
  Rel(storage, table, "Управление таблицами")
  Rel(query, table, "Чтение")
  Rel(catalog, table, "Метаданные/lineage")

  Rel(acl, dwh, "Читает legacy")
  Rel(acl, bus, "Публикует нормализованные события")
  Rel(esb, bus, "Мост на время миграции")
```

## Уровень 3 — Component (домен Финтех как пример продукта данных)

```mermaid
C4Component
  title Компоненты продукта данных домена «Финтех»

  ContainerQueue(bus, "Kafka", "events + DLQ + Schema Registry")
  ContainerDb(storage, "S3/MinIO", "зона домена finance")
  Container(catalog, "DataHub", "каталог")

  Container_Boundary(fin, "Финтех Data Product") {
    Component(producer, "Event Producer", "Go", "Публикует доменные события")
    Component(ingest, "Ingestion / Stream processor", "Flink/Spark", "Потоковая обработка в Iceberg")
    Component(contract, "Data Contract + JSON Schema", "—", "Версионируемый контракт продукта")
    Component(quality, "Data Quality checks", "Great Expectations", "Проверки качества, метрики")
    Component(mart, "Потоковая витрина", "Iceberg table", "Near-real-time данные финдомена")
    Component(api, "Output Port API", "REST/SQL", "Потребление другими доменами")
  }

  Rel(producer, bus, "publish")
  Rel(bus, ingest, "consume")
  Rel(ingest, mart, "write")
  Rel(ingest, quality, "validate")
  Rel(contract, bus, "Schema Registry")
  Rel(mart, storage, "хранение")
  Rel(api, mart, "read")
  Rel(catalog, mart, "регистрация продукта, lineage")
```

## Как изменятся ключевые системы за год

| Сейчас | Через год |
|---|---|
| Монолитный DWH (SQL Server 2008) с бизнес-логикой | DWH → мост совместимости (CDC), бизнес-логика вынесена в домены; цель — вывод из эксплуатации |
| ESB Camel как центр синхронных интеграций | Kafka + событийная интеграция; Camel только как ACL-мост |
| Power BI поверх кастомизаций DWH | Портал самообслуживания (Self-service BI) поверх Data Mesh |
| Единая команда хранилища = «бутылочное горлышко» | Доменные команды владеют своими продуктами данных |
| Batch-отчётность (часы) | Near-real-time потоковые витрины |
| Новые направления тяжело подключать | Новый домен = новый продукт данных + подписки на события |
