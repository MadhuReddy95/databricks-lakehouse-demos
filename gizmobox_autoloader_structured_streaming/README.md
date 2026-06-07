# Databricks Auto Loader — Incremental File Ingestion

Cloud-optimized, incremental ingestion of customer records into a Delta **bronze** table using **Auto Loader** (`cloudFiles`). Same goal as the Structured Streaming demo, different (more scalable) ingestion engine.

## Notebook
| Notebook | Purpose |
|---|---|
| `Autoloader.ipynb` | `spark.readStream.format("cloudFiles")` with a persisted `schemaLocation`, `inferColumnTypes`, and `schemaHints` → adds lineage columns → `writeStream` to a Delta bronze table with checkpointing. |

## Auto Loader vs. plain Structured Streaming
| | Structured Streaming (`json`) | Auto Loader (`cloudFiles`) |
|---|---|---|
| Schema | inferred per run / supplied | persisted + evolving via `schemaLocation` |
| File discovery | re-lists the directory | efficient incremental listing / file notifications |
| Scales to high file volume | limited | yes |

## Setup
This project reuses the `gizmobox` catalog and volume created by the setup notebook in the sibling project: [`../gizmobox_structured_streaming/Gizmobox_Stream_Setup.ipynb`](../gizmobox_structured_streaming/Gizmobox_Stream_Setup.ipynb). Run that once first.

## How to run
1. Ensure the `gizmobox` catalog, schemas, and volume exist (run the setup notebook above).
2. Land the sample files from `Data/` into the Auto Loader source path.
3. Run `Autoloader.ipynb`; rerunning only picks up newly arrived files, Auto Loader remembers what it already processed.

## Data
`Data/` contains sample monthly customer records (`customers_2024_10.json` … `customers_2025_01.json`).
