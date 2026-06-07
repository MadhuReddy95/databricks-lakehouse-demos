# Spark Structured Streaming — JSON → Delta (Bronze)

Real-time micro-batch ingestion of customer records into a Delta **bronze** table using Spark Structured Streaming.

## Notebooks
| Notebook | Purpose |
|---|---|
| `setup.ipynb` | One-time Unity Catalog setup: external location, `retail_stream` catalog, `landing` / `bronze` / `silver` / `gold` schemas, and an external volume. |
| `structured_streaming.ipynb` | `spark.readStream` over the landing folder (schema inferred via `schema_of_json`) → adds lineage columns (`file_path`, `ingestion_date`) → `writeStream` to a Delta bronze table with a 10-second micro-batch trigger and checkpointing. |

## Concepts demonstrated
`readStream` / `writeStream`, schema inference, micro-batch trigger intervals, and checkpointing for fault-tolerant, restartable streams.

## Structured Streaming vs. Auto Loader

This demo uses **plain Structured Streaming** (`format("json")`): the schema is supplied up front and the source directory is re-listed on each trigger. Simple, but it doesn't scale to very high file counts. For the cloud-optimized alternative (a persisted, evolving schema plus efficient incremental file discovery via `cloudFiles`), see the sibling project [`../autoloader`](../autoloader).

## How to run
1. Run `setup.ipynb` once to create the catalog, schemas, and volume.
2. Land the sample files from `Data/` into the volume's `customers_stream` path.
3. Run `structured_streaming.ipynb` and watch each new file process as a micro-batch into `retail_stream.bronze.customers_stream`.

## Data
`Data/` contains sample monthly customer records (`customers_2024_10.json` … `customers_2025_01.json`).
