class Photo < ActiveRecord::Base
  belongs_to :entry, polymorphic: true

  mount_uploader :photo_data, PhotoDataUploader
end
