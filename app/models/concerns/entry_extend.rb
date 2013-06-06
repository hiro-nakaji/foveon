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
end
