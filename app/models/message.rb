class Message < ActiveRecord::Base
  acts_as_tree order: 'created_at'
  has_many :photos, -> { order "no" }, dependent: :destroy
end
