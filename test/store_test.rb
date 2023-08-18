require "minitest/autorun"
require "stores"

require "tempfile"

describe SqliteStore do
  before do
    @tempfile = Tempfile.new("store.db")
    @store = SqliteStore.new(@tempfile.path)
  end

  after do
    @tempfile.close
    @tempfile.unlink
  end

  describe "upsert_org" do
    it "inserts a new organization" do
      @store.upsert_org(1, "Org A")

      org = @store.get_org_name(1)
      _(org["name"]).must_equal("Org A")
    end

    it "updates a new organization" do
      @store.upsert_org(1, "Org A")
      @store.upsert_org(1, "Org B")

      org = @store.get_org_name(1)
      _(org["name"]).must_equal("Org B")
    end
  end

  describe "upsert_inspection" do
    it "inserts a new inspection" do
      @store.upsert_org(1, "Org A")

      date = Date.parse("2020-01-01")

      @store.upsert_inspection(
        vehicle_id: 1,
        inspection_date: date,
        organization_id: 1,
        inspection_period_id: 1,
        inspection_passed: nil,
      )

      vehicle = @store.get_inspection_by_vehicle_and_date(1, date)
      _(vehicle["vehicle_id"]).must_equal(1)
      _(vehicle["inspection_date"]).must_equal("2020-01-01")
      _(vehicle["organization_id"]).must_equal(1)
      _(vehicle["inspection_period_id"]).must_equal(1)
      _(vehicle["inspection_passed"]).must_equal(nil)
    end

    it "updates a inspection" do
      @store.upsert_org(1, "Org A")

      date = Date.parse("2020-01-01")
      @store.upsert_inspection(
        vehicle_id: 1,
        inspection_date: date,
        organization_id: 1,
        inspection_period_id: 1,
        inspection_passed: nil,
      )

      @store.upsert_inspection(
        vehicle_id: 1,
        inspection_date: date,
        organization_id: 2,
        inspection_period_id: 1,
        inspection_passed: true,
      )

      vehicle = @store.get_inspection_by_vehicle_and_date(1, date)
      _(vehicle["vehicle_id"]).must_equal(1)
      _(vehicle["inspection_date"]).must_equal("2020-01-01")
      _(vehicle["organization_id"]).must_equal(2)
      _(vehicle["inspection_period_id"]).must_equal(1)
      _(vehicle["inspection_passed"]).must_equal(true)
    end
  end
end
