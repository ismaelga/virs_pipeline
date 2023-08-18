require "./lib/stores"
require "./lib/pipeline"
require "./lib/ingestion"

ENGINE = Pipeline.new(
  Ingestion.new("./virs_pipeline/vehicle_inspection_reports/"),
  SqliteStore.new("./virs.db")
)
