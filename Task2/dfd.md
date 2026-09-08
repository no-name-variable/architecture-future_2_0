# Data Flow Diagram целевой архитектуры

```mermaid
flowchart LR
  clinic[Клиники и операторы]
  bank[Финтех и банк]
  ai[ИИ-компания]
  partners[Фармацевтика и производитель оборудования]
  analyst[Бизнес-пользователь]

  subgraph medical[Домен Medical]
    medp((Пациентский и лечебный процессы))
    meddb[(Операционная медицинская БД)]
    medp <--> |карта, назначение, статус приёма| meddb
  end

  subgraph finance[Домен Finance]
    finp((Кредиты и платежи))
    findb[(Финансовая БД)]
    finp <--> |договоры, счета, транзакции| findb
  end

  subgraph aiml[Домен AI]
    aip((Исследование и инференс))
    aidb[(Хранилище моделей и результатов)]
    aip <--> |модель, технический результат| aidb
  end

  subgraph ecosystem[Домен Partner Integration]
    pp((Адаптеры партнёров))
  end

  bus[(Kafka + Schema Registry + DLQ)]
  catalog[(Data Catalog / Lineage)]

  subgraph analytics[Домен Analytics Platform]
    ingest((Проверка, минимизация и загрузка))
    lake[(S3 + Iceberg Lakehouse)]
    query((Dremio / Trino))
    portal((Портал самообслуживания))
    ingest --> |разрешённые доменные данные| lake
    lake --> query --> portal
  end

  clinic --> |регистрация, лечение| medp
  bank --> |кредит, платёж| finp
  medp --> |запрос исследования| bus
  bus --> |задание без лишних ПДн| aip
  aip --> |исследование завершено| bus
  bus --> |результат для лечебного процесса| medp
  finp --> |договор и платёж проведены| bus
  medp --> |факт регистрации без медкарты| bus
  partners <--> |контракт партнёра| pp
  pp <--> |версионируемые события| bus
  bus --> |аналитические события| ingest
  catalog <--> |схемы, владельцы, lineage| ingest
  analyst --> |отчёт в пределах RBAC/ABAC| portal
```

Граница аналитики принимает только разрешённые события и атрибуты. Медицинские
карты, истории болезни и содержимое исследований остаются в домене Medical и в
аналитическую витрину не передаются.
