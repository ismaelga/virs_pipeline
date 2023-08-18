require "csv"

# Organizations
# Vehicles
# Inspections

class Pipeline
  attr_reader :ingestor, :store

  def initialize(ingestor, data_store)
    @ingestor = ingestor
    @store = data_store
  end

  def load_data
    # last_update = store.get_last_update
    # ingestor.ingest_updates(last_update)
    ingestor.ingest_updates.each do |updates|
      orgs, inspections = updates

      handle_orgs(orgs)
      handle_inspections(inspections)
    end
    
    puts "Loaded data..."
  end

  def handle_orgs(orgs)
    orgs.each do |id, org_name|
      store.upsert_org(id, org_name)
    end
  end

  def handle_inspections(inspections)
    inspections.each do |id, inspection|
      store.upsert_inspection(
        vehicle_id: inspection.vehicle_id,
        inspection_date: inspection.inspection_date,
        organization_id: inspection.vehicle_org_id,
        inspection_period_id: inspection.inspection_period_id,
        inspection_passed: inspection.inspection_passed,
      )
    end
  end

  def report(file)
    report = store.report
    export(file, report)
  end

  def export(file, report)
    headers = []
    CSV.open(file, "wb", headers: ["org_name", "tot_v", "failed_v"], write_headers: true, col_sep: "\t") do |tsv|
      report.each do |l|
        puts l.inspect
        tsv << [l["name"], l["tot_v"], l["failed_v"]]
      end
    end
  end
end
