class Message < ActiveRecord::Base
  scope :desc, -> { order('created_at DESC') }
  scope :newer, ->(created_at) { where('created_at >= ?', created_at) }

  include Entry
  extend EntryExtend

  has_many :comments, dependent: :destroy, order: :created_at

  def current_page
    count = Message.newer(self.created_at).count
    (count.to_f / Kaminari.config.default_per_page).ceil
  end
end
