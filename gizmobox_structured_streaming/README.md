# Spark Structured Streaming — JSON → Delta (Bronze)

Real-time micro-batch ingestion of customer records into a Delta **bronze** table using Spark Structured Streaming.

## Notebooks
| Notebook | Purpose |
|---|---|
| `Gizmobox_Stream_Setup.ipynb` | One-time Unity Catalog setup: external location, `gizmobox` catalog, `landing` / `bronze` / `silver` / `gold` schemas, and an external volume. |
| `Structured_Streaming.ipynb` | `spark.readStream` over the landing folder (schema inferred via `schema_of_json`) → adds lineage columns (`file_path`, `ingestion_date`) → `writeStream` to a Delta bronze table with a 10-second micro-batch trigger and checkpointing. |

## Concepts demonstrated
`readStream` / `writeStream`, schema inference, micro-batch trigger intervals, and checkpointing for fault-tolerant, restartable streams.

## How to run
1. Run `Gizmobox_Stream_Setup.ipynb` once to create the catalog, schemas, and volume.
2. Land the sample files from `Data/` into the volume's `customers_stream` path.
3. Run `Structured_Streaming.ipynb` and watch each new file process as a micro-batch into `gizmobox.bronze.customers_stream`.

## Data
`Data/` contains sample monthly customer records (`customers_2024_10.json` … `customers_2025_01.json`).
