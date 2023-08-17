require "minitest/autorun"
require "ingestion"

describe Ingestion do
  before do
    @ingestor = Ingestion.new("test/samples/")
  end

  describe "all_files" do
    it "returns all matching files on directory" do
      _(@ingestor.all_files).must_equal(
        ["test/samples/vir_202006.csv", "test/samples/vir_202007.csv"]
      )
    end
  end

  describe "parse_file" do
    it "fails on invalid header" do
      assert_raises(Ingestion::UnmatchedHeaderError) do
        @ingestor.parse_file("test/samples/invalid_vir_202006.csv")
      end
    end

    it "parses one file" do
      parsed = @ingestor.parse_file("test/samples/vir_202006.csv")[0]

      _(parsed).must_equal(
        Inspection.new(2811, Date.parse("2020-02-06"), 1920, "Economotor", 102, false)
      )
    end

    it "parses quotes correctly" do
      parsed = @ingestor.parse_file("test/samples/vir_202006.csv")[-1]

      _(parsed.org_name).must_equal('Cars "R" Us')
    end
  end

  describe "ingest_updates" do
    it "returns organizations with last updated names" do
      res = @ingestor.ingest_updates

      _(res[0][0])
        .must_equal(
          {1920=>"Economotor", 7732=>"Mina Fleet Trucks", 2265=>"Cars \"R\" Us"}
        )

      _(res[1][0])
        .must_equal(
          {1920=>"Economotor2", 7732=>"Mina Fleet Trucks", 2265=>"Cars \"R\" Us 2"}
        )
    end

    it "returns vehicles with last updated states" do
      res = @ingestor.ingest_updates

      _(res[1][1].map {|id, i| [id, i.vehicle_id, i.inspection_date.to_s, i.vehicle_org_id, i.inspection_period_id, i.inspection_passed]})
        .must_equal(
          [
            [2811, 2811, "2020-02-06", 1920, 102, true],
            [4021, 4021, "2020-02-10", 1920, 102, true],
            [1508, 1508, "2020-02-12", 7732, 102, true],
            [1509, 1509, "2020-02-12", 7732, 102, nil],
            [4919, 4919, "2020-02-14", 2265, 102, true]
          ]
        )
    end
  end
end
