class Message < ActiveRecord::Base
  scope :roots, -> { where(parent_id: nil).order('created_at DESC')}
  scope :desc, -> { order('created_at DESC') }
  acts_as_tree order: 'created_at'

  has_many :photos, -> { order "no" }, dependent: :destroy

  def url
    return nil if self.homepage.empty?

    if /^http\:\/\// =~ self.homepage
      self.homepage
    else
      "http://" + self.homepage
    end
  end

  def root
    if parent.nil?
      self
    else
      parent.root
    end
  end
end
