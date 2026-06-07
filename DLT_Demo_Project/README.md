# Delta Live Tables — Bronze → Silver → Gold Declarative Pipeline

An end-to-end streaming pipeline in **Databricks Delta Live Tables (DLT)** that ingests raw JSON/CSV from a landing zone and incrementally curates it into analytics-ready Delta tables using the **Bronze → Silver → Gold** Lakehouse architecture.

## Project structure

```
DLT_Demo_Project/
├── 1_DLT_Demo_Project_Setup.ipynb          # Unity Catalog + ADLS setup (run once)
├── 2_DLT_Demo/
│   └── transformations/
│       ├── bronze.sql                       # raw streaming ingestion (Auto Loader)
│       ├── silver.sql                       # cleansing + data quality + SCD 1 / SCD 2
│       └── gold.sql                         # business-ready materialized view
├── Data/                                    # sample datasets
│   ├── customers/   (JSON)
│   ├── orders/      (JSON)
│   └── addresses/   (CSV)
└── images/                                  # pipeline screenshots
```

## 1. Setup notebook

`1_DLT_Demo_Project_Setup.ipynb` initializes the Unity Catalog foundations:

- Storage credential and external location for ADLS (landing and Delta zones).
- The `circuitbox` catalog, the `landing` / `deltalake` schemas, and an external volume for operational data.

## 2. Pipeline layers (`2_DLT_Demo/transformations/`)

| File | Layer | What it does |
|---|---|---|
| `bronze.sql` | Bronze | Streaming ingest from the landing volume via Auto Loader (`cloud_files()`) — JSON for customers/orders, CSV for addresses — with schema inference and evolution. Adds `input_file_path` and `ingestion_timestamp`. |
| `silver.sql` | Silver | `EXPECT` data-quality constraints (`FAIL UPDATE` / `DROP ROW`), then `APPLY CHANGES INTO` for CDC: **SCD Type 1** (customers, orders) and **SCD Type 2** (addresses). Orders are exploded to line-item grain. |
| `gold.sql` | Gold | Materialized view joining the curated tables (current SCD-2 rows via `__END_AT IS NULL`) into a customer-order summary with order counts, item totals, and amounts. |

## Data flow

Landing zone (ADLS) → Bronze → Silver → Gold

| Domain | Format | Change type | Notes |
|---|---|---|---|
| Customers | JSON | SCD Type 1 | latest record overwrites |
| Orders | JSON | SCD Type 1 | latest transactional state; exploded to line items |
| Addresses | CSV | SCD Type 2 | history preserved via effective/expiry timestamps |

## How to run

1. Run `1_DLT_Demo_Project_Setup.ipynb` to register the storage credential, external location, volume, catalog, and schemas.
2. Create a **Delta Live Tables pipeline** pointing at `2_DLT_Demo/transformations/`, and run it in **continuous** mode for near-real-time freshness.

## Pipeline screenshots

**Pipeline settings (continuous mode)**

<img src="images/image1.png" alt="DLT pipeline settings" width="400"/>

**Pipeline DAG (continuous trigger)**

<img src="images/image2.png" alt="DLT pipeline DAG" width="600"/>

**Azure cloud data load**

<img src="images/image3.png" alt="Azure data load" width="500"/>

**DAG processing new incoming data**

<img src="images/image4.png" alt="DLT DAG processing new data" width="600"/>
