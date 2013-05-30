module Entry
  def self.included(base)
    base.has_many :photos, -> { order "no" }, as: :entry, dependent: :destroy
  end

  def url
    return nil if self.homepage.empty?

    if /^http\:\/\// =~ self.homepage
      self.homepage
    else
      "http://" + self.homepage
    end
  end
end