module Entry
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
    entry.content = I18n.t('entry.wrote', author: self.author) + "\n"
    entry.content += self.content.gsub(/^/, "> ")
  end

  def new_entry?(current_time = Time.now)
    self.updated_at > current_time - 24.hours
  end

  def search_hit?(input)
    self.class.split_to_words(input).each do |word|
      return true if self.title =~ /#{word}/ || self.author =~ /#{word}/ || self.content =~ /#{word}/
    end
    return false
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