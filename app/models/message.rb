class Message < ActiveRecord::Base
  scope :desc, -> { order('created_at DESC') }

  include Entry
  extend EntryExtend

  has_many :comments, dependent: :destroy, order: :created_at
end
