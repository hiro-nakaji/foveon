class Message < ActiveRecord::Base
  include Entry
  extend EntryExtend

  has_many :comments, ->{order(:created_at)}, dependent: :destroy

  scope :desc, -> { order(created_at: :desc) }
  scope :newer, ->(created_at) { where('created_at >= ?', created_at) }

  scope :search_title, ->(word) { where(arel_table[:title].matches word) }
  scope :search_author, ->(word) { where(arel_table[:author].matches word) }
  scope :search_content, ->(word) { where(arel_table[:content].matches word) }
  scope :search, ->(word){search_title(word).search_author(word).search_content(word)}

  def current_page
    count = Message.newer(self.created_at).count
    (count.to_f / Kaminari.config.default_per_page).ceil
  end

  def self.search_from_input(input)
    comment_where = Comment.where_from_input(input)
    comment_select =  Comment.select(:message_id).where(comment_where)

    message_where = Message.where_from_input(input)
    
    Message.where(Message.where(message_where).where(id: comment_select).where_values.reduce(:or))
  end
end
