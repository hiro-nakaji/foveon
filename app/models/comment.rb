class Comment < ActiveRecord::Base
  include Entry

  belongs_to :message
end
