module Entry
  def build_photos_up_to_max
    if self.photos.size < Settings.max_photo_count
      (Settings.max_photo_count - self.photos.size).
        times do |index|
        photo = self.photos.max{|a,b| a.no <=> b.no}
        no = photo ? photo.no + 1 : 0
        self.photos.build(no: no)
      end
    end
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

  # @param request ActionDispatch::Request
  def log_request(request)
    update_attributes(remote_addr: request.remote_addr, user_agent: request.user_agent)
  end

  private

  def check_multibyte
    if self.title.size == self.title.bytesize &&
      self.author.size == self.author.bytesize && self.content.size == self.content.bytesize
      errors.add(:base, :multibyte)
    end
  end

  def check_passwords
    unless self.password.blank? || Digest::SHA1.hexdigest(self.password) == self.password_was
      errors.add(:password, :invalid)
    end
  end

  def crypt_password
    if self.password_changed?
      self.password = Digest::SHA1.hexdigest(self.password)
    end
  end
end