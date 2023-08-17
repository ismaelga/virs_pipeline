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
  end

  describe "ingest_updates" do
    it "returns parsed data" do
      # _(@ingestor.ingest_updates).must_equal(
      #   []
      # )
    end
  end
end
