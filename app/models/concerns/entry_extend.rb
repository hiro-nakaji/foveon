module EntryExtend
  def self.extended(base)
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
    base.validate :check_multibyte, if: -> { title? && author? && content? }

    base.before_save :crypt_password

    base.scope :desc, -> { base.order(created_at: :desc) }
    base.scope :search_title, ->(word) { base.where(base.arel_table[:title].matches "%#{word}%") }
    base.scope :search_author, ->(word) { base.where(base.arel_table[:author].matches "%#{word}%") }
    base.scope :search_content, ->(word) { base.where(base.arel_table[:content].matches "%#{word}%") }
    base.scope :search, ->(word){base.search_title(word).search_author(word).search_content(word)}
  end

  def permitted_create_params
    [:title, :author, :password, :mail, :homepage, :content,
     photos_attributes: [:id, :title, :photo_data, :no, :photo_data_cache, :_destroy]]
  end

  def permitted_update_params
    [:title, :author, :password, :mail, :homepage, :content,
     photos_attributes: [:id, :title, :photo_data, :no, :photo_data_cache, :_destroy]]
  end

  def permitted_destroy_params
    [:password]
  end

  def where_from_input(input)
    wheres = self.split_to_words(input).map do |word|
      self.search(word).where_values.reduce(:or)
    end
    wheres.inject {|where1, where2| where1.or(where2)}
  end

  def split_to_words(input)
    input.split(/[#{Settings.spaces}]+/)
  end

  def cookie_keys
    [:author, :mail, :homepage]
  end
end