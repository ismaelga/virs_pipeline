require "minitest/autorun"
require "pipeline"

describe Pipeline do
  before do
    @ingestor = Minitest::Mock.new
    @store = Minitest::Mock.new
    @pipeline = Pipeline.new(@ingestor, @store)
  end

  describe "load_data" do
    it "calls" do
      @ingestor.expect(:ingest_updates, [])
      @pipeline.load_data
    end
  end
end
