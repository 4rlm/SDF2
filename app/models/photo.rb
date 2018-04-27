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


  has_attached_file :csv
  validates_attachment :csv, content_type: { content_type: "text/csv" }

end
