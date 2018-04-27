class S3 < ApplicationRecord
  # belongs_to :user

  # has_attached_file :csv
  has_attached_file :csv, styles: { path: ":attachment/:id/:style.:extension" }
  validates_attachment :csv, content_type: { content_type: "text/csv" }

  def generate_s3_csv(foos, options = {})
    s3 = self
    file_name = 'test_csv'

    final_csv = CSV.generate(options) do |csv|
      foo_cols = foos.first.attributes.keys
      csv.add_row(foo_cols)

      foos.each do |foo|
        foo_vals = foo.attributes.slice(*foo_cols).values
        csv.add_row(foo_vals)
      end

      file = StringIO.new(csv.string)
      s3.csv = file
      s3.csv.instance_write(:content_type, 'text/csv')
      s3.csv.instance_write(:file_name, file_name)
      s3.save!
    end

    # path = s3.csv.url
    # FileUtils.mkdir_p(path) unless File.exist?(path)
    # File.open(File.join(s3.csv.url), 'wb') do |file|
    #   file.puts f.read
    # end
  end

end
