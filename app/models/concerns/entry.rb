module Entry
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