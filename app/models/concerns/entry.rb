module Entry
  def self.included(base)
    base.has_many :photos, -> { order "no" }, as: :entry, dependent: :destroy

    base.accepts_nested_attributes_for :photos

    base.validates :title, presence: true
    base.validates :author, presence: true
    base.validates :password, presence: true
    base.validates :content, presence: true
    base.validates :mail, email_format: {allow_blank: true}
    base.validates :homepage, url: {allow_blank: true}

    base.validate :check_passwords, if: :persisted?

    base.before_save :remove_unavailable_photos, :crypt_password

  end

  def url
    return nil if self.homepage.empty?

    if /^http\:\/\// =~ self.homepage
      self.homepage
    else
      "http://" + self.homepage
    end
  end

  private

  def remove_unavailable_photos
    self.photos.each do |photo|
      self.photos.delete(photo) if photo.new_record? && photo.image.nil?
    end
  end

  def check_passwords
    unless self.password.crypt(self.password_was) == self.password_was
      errors.add(:password, :invalid)
    end
  end

  def crypt_password
    if self.password_changed?
      salt = [rand(64), rand(64)].pack("C*").tr("\x00-\x3f", "A-Za-z0-9./")
      self.password  = self.password.crypt(salt)
    end
  end
end