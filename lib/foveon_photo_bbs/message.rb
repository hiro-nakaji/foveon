class FoveonPhotoBbs::Message

  attr_reader :id, :parent_id, :created_at, :author, :mail, :hopmepage, :title,
              :content, :color, :password, :remote_address, :photos
  # @param line_data String
  def initialize(line_data)
    elements        = line_data.split(Settings.photo_bbs.separator, 12)
    @id             = elements[0]
    @parent_id      = elements[1]
    @created_at     = Time.parse(elements[2].gsub(/\(.\)/, ''))
    @updated_at     = Time.parse(elements[2].gsub(/\(.\)/, ''))
    @author         = elements[3]
    @mail           = elements[4]
    @homepage       = elements[5]
    @title          = elements[6]
    @content        = elements[7]
    @color          = elements[8]
    @password       = elements[9]
    @remote_address = elements[10]
    @photos         = FoveonPhotoBbs::Photo.initialize(@id, elements[11])
  end

  # Return Hash for a 'Message'
  #
  # @return Hash
  def message_hash
    homepage = @homepage
    homepage = "http://" + homepage unless homepage.blank? || homepage.start_with?('http')
    title = @title || '無題'
    {
      old_id:         @id,
      created_at:     @created_at,
      updated_at:     @updated_at,
      author:         @author.present? ? @author : '無名',
      mail:           @mail,
      homepage:       homepage,
      title:          @title.present? ? @title : '無題',
      content:        @content.gsub(/<(br|BR)>/, "\n"),
      remote_addr:    @remote_address,
      message_type:   'photo',
      password:       [*1..9, *'A'..'Z', *'a'..'z'].sample(8).join
    }
  end
end