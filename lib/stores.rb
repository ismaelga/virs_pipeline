require "sqlite3"

class SqliteStore
  attr_reader :db

  def initialize(file)
    @db = SQLite3::Database.open(file)
    setup
  end

  def get_something
    results = db.query("SELECT path, thumbs_up FROM images WHERE path=?", image_path)
  end

  def get_last_update
    results = db.query("SELECT path, thumbs_up FROM images WHERE path=?, ORDER BY created_at, LIMIT 1")
  end

  def upsert_org(id, name)
    db.execute(
      "
      INSERT INTO organizations(id, name)
      VALUES(?, ?)
      ON CONFLICT(id) DO UPDATE SET name=excluded.name
      ",
      [id, name]
    )
  end

  def get_org_name(id)
    db.query("SELECT * FROM organizations WHERE id=? LIMIT 1", [id]).next
  end

  def upsert_inspection(vehicle_id:, inspection_date:, organization_id:, inspection_period_id:, inspection_passed:)
    db.execute(
      "
      INSERT INTO vehicle_inspections(
        vehicle_id, inspection_date, organization_id, inspection_period_id, inspection_passed
      )
      VALUES(?, ?, ?, ?, ?)
      ON CONFLICT(vehicle_id, inspection_date)
      DO UPDATE SET
        organization_id=excluded.organization_id,
        inspection_passed=excluded.inspection_passed
      ",
      [
        vehicle_id,
        inspection_date.to_s,
        organization_id,
        inspection_period_id,
        inspection_passed.nil? ? nil : (inspection_passed ? 1 : 0)
      ]
    )
  end

  def get_inspection_by_vehicle_and_date(id, date)
    r = db.query("SELECT * FROM vehicle_inspections WHERE vehicle_id=? AND inspection_date=? LIMIT 1", [id, date.to_s]).next
    parse_inspection(r)
  end

  def parse_inspection(r)
    r["inspection_passed"] = r["inspection_passed"].nil? ? nil : !!r["inspection_passed"]
    r
  end

  def setup
    db.results_as_hash = true

    db.execute("CREATE TABLE IF NOT EXISTS organizations(id INT, name TEXT)")
    db.execute("CREATE UNIQUE INDEX IF NOT EXISTS organizations_id_idx ON organizations(id);")

    db.execute(
      "CREATE TABLE IF NOT EXISTS vehicle_inspections(vehicle_id INT, inspection_date DATE, organization_id INT, inspection_period_id INT, inspection_passed BOOLEAN)"
    )
    db.execute("CREATE UNIQUE INDEX IF NOT EXISTS inspection_idx ON vehicle_inspections(vehicle_id, inspection_date);")
    db.execute("CREATE INDEX IF NOT EXISTS vehicle_org_id_idx ON vehicle_inspections(organization_id);")
    db.execute("CREATE INDEX IF NOT EXISTS vehicle_id_idx ON vehicle_inspections(vehicle_id);")
  end
end
