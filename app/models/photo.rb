class Photo < ApplicationRecord

  # belongs_to :user
  # belongs_to :article

  # has_attached_file :image,
  # styles: { thumb: ["150x150#", :jpg], original: ['500x500>', :jpg] },
  # convert_options: { thumb: "-quality 75 -strip", original: "-quality 85 -strip" }
  #
  # validates_attachment :image, presence: true,
  # content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] },
  # size: { in: 0..1000.kilobytes }


  has_attached_file :csv, styles: { path: ":attachment/:id/:style.:extension" }
  # has_attached_file :csv
  validates_attachment :csv, content_type: { content_type: "text/csv" }



  def generate_s3_csv(foos, options = {})
    photo = self
    file_name = 'test_csv'

    CSV.generate(options) do |csv|
      foo_cols = foos.first.attributes.keys
      csv.add_row(foo_cols)

      foos.each { |foo| foo.attributes.slice(*foo_cols).values }
      file = StringIO.new(csv.string)
      photo.csv = file
      photo.csv.instance_write(:content_type, 'text/csv')
      photo.csv.instance_write(:file_name, file_name)
      photo.save!
    end

    # path = photo.csv.url
    # FileUtils.mkdir_p(path) unless File.exist?(path)
    # File.open(File.join(photo.csv.url), 'wb') do |file|
    #   file.puts f.read
    # end
  end


end
