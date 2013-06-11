class Comment < ActiveRecord::Base
  include Entry
  extend EntryExtend

  belongs_to :message
end
