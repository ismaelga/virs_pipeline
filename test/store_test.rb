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

end
