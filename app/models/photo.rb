class Photo < ActiveRecord::Base
  belongs_to :entry, polymorphic: true
end
