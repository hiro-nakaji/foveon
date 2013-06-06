module Entry
  def self.included(base)
    base.has_many :photos, -> { order "no" }, as: :entry, dependent: :destroy

    base.accepts_nested_attributes_for :photos,
                                       allow_destroy: true,
                                       reject_if: ->(attr) {
                                         attr[:photo_data].blank? && attr[:photo_data_cache].blank? && attr[:_destroy].blank?
                                       }

    base.validates :title, presence: true
    base.validates :author, presence: true
    base.validates :password, presence: true
    base.validates :content, presence: true
    base.validates :mail, email_format: {allow_blank: true}
    base.validates :homepage, url: {allow_blank: true}

    base.validate :check_passwords, on: :update, if: :password_changed?

    base.before_save :crypt_password

    base.scope :search_title, ->(word) { base.where(base.arel_table[:title].matches word) }
    base.scope :search_author, ->(word) { base.where(base.arel_table[:author].matches word) }
    base.scope :search_content, ->(word) { base.where(base.arel_table[:content].matches word) }
    base.scope :search, ->(word){base.search_title(word).search_author(word).search_content(word)}
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
    if self.photos.size < Settings.foveon_bbs.max_photo_count
      (Settings.foveon_bbs.max_photo_count - self.photos.size).
        times do |index|
        photo = self.photos.max{|a,b| a.no <=> b.no}
        no = photo ? photo.no + 1 : 0
        self.photos.build(no: no)
      end
    end
  end

  def reply(entry)
    entry.title = self.title.gsub(/^/, "Re: ")
    entry.content = self.content.gsub(/^/, "> ")
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