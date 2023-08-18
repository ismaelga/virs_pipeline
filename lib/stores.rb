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
    db.query("SELECT id, name FROM organizations WHERE id=? LIMIT 1", [id]).next
  end

  def setup
    db.results_as_hash = true

    db.execute("CREATE TABLE IF NOT EXISTS organizations(id INT, name TEXT)")
    db.execute("CREATE UNIQUE INDEX IF NOT EXISTS organizations_id_index ON organizations(id);")

  end
end
