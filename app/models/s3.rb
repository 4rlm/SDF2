class S3 < ApplicationRecord
  # belongs_to :user

  # has_attached_file :csv

  has_attached_file :csv,
                    storage: :s3,
                    s3_credentials: {
                      bucket: ENV['AWS_BUCKET'],
                      access_key_id: ENV['AWS_KEY_ID'],
                      secret_access_key: ENV['AWS_SECRET_KEY']
                    },
                    s3_region: ENV['AWS_S3_REGION'],
                    s3_headers: -> (attachment) {
                      {
                        'Content-Type': 'text/csv',
                        'Content-Disposition': "attachment; filename=#{attachment.csv_name}.csv"
                      }
                    }

  validates_attachment :csv, content_type: { content_type: "text/csv" }

  def generate_s3_csv(foos, options = {})
    s3 = self
    file_name = 'test_csv.csv'

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

  end

  def csv_name
    Time.now.strftime("%Y%m%d%I%M%S")
  end


end
