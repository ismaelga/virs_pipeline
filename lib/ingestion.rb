require "csv"
require "date"
require "inspection"

# vehicle_id|inspection_date|vehicle_org_id|org_name|inspection_period_id|inspection_passed
# 2811|2020-02-06|1920|Economotor|102|TRUE
# 4021|2020-02-10|1920|Economotor|102|TRUE

class Ingestion
  attr_reader :source_dir, :separator, :headers_mapper

  class UnmatchedHeaderError < StandardError
  end

  def initialize(dir)
    @source_dir = dir
    @separator = "|"
    @headers_mapper = %i[
      vehicle_id
      inspection_date
      vehicle_org_id
      org_name
      inspection_period_id
      inspection_passed
    ]
  end

  def ingest_updates(_last_update = nil)
    all_files.each do |file|
      parse_file(file)
    end
  end

  def all_files
    Dir.glob(source_dir + "vir_*.csv")
  end

  def parse_file(file)
    year, month = file.scan(/vir_(\d{4})(\d{2})\.csv/)[0]

    headers = File.open(file, "r").gets.strip
    raise UnmatchedHeaderError, "\nexpected: '#{expected_header}'\n     got: '#{headers}'" if headers != expected_header

    results = []
    CSV.foreach(file, headers: :first_row, return_headers: false, col_sep: "|") do |row|
      results << Inspection.new(
        row["vehicle_id"].to_i,
        Date.parse(row["inspection_date"]),
        row["vehicle_org_id"].to_i,
        row["org_name"],
        row["inspection_period_id"].to_i,
        row["inspection_passed"] == "TRUE"
      )
    end

    results
  end

  def expected_header
    headers_mapper.join(separator)
  end
end
