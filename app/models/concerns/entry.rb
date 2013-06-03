module Entry
  def self.included(base)
    base.has_many :photos, -> { order "no" }, as: :entry, dependent: :destroy

    base.accepts_nested_attributes_for :photos,
                                       reject_if: :all_blank,
                                       allow_destroy: true

    base.validates :title, presence: true
    base.validates :author, presence: true
    base.validates :password, presence: true
    base.validates :content, presence: true
    base.validates :mail, email_format: {allow_blank: true}
    base.validates :homepage, url: {allow_blank: true}

    base.validate :check_passwords, if: :persisted?

    base.before_save :crypt_password

  end

  def url
    return nil if self.homepage.empty?

    if /^http\:\/\// =~ self.homepage
      self.homepage
    else
      "http://" + self.homepage
    end
  end

  def build_photos_up_to_max
    if self.photos.count < Settings.foveon_bbs.max_photo_count
      (Settings.foveon_bbs.max_photo_count - self.photos.count).
        times do |index|
        self.photos.build
      end
    end
  end

  private

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