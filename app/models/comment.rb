class Comment < ActiveRecord::Base
  include Entry
  extend EntryExtend

  belongs_to :message

  scope :search_title, ->(word) { where(arel_table[:title].matches word) }
  scope :search_author, ->(word) { where(arel_table[:author].matches word) }
  scope :search_content, ->(word) { where(arel_table[:content].matches word) }
  scope :search, ->(word){search_title(word).search_author(word).search_content(word)}

end
