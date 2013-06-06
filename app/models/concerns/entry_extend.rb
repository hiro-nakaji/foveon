module EntryExtend
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
    input.split(/[#{Settings.foveon_bbs.spaces}]+/)
  end
end