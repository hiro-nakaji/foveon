class FoveonPhotoBbs::Photo

  attr_reader :no, :extension, :width, :height, :title

  # @param message_id String
  # @param raw_data String
  # @return Array array of FoveonPhotoBbs::Photo
  def self.initialize(message_id, raw_data)
    elements = raw_data.split(Settings.photo_bbs.separator)
    items = []
    Settings.photo_bbs.photos.times do |index|
      extension = elements[4 * index + 0]
      width = elements[4 * index + 1]
      height = elements[4 * index + 2]
      title = elements[4 * index + 3]
      if extension.present?
        items << FoveonPhotoBbs::Photo.new(message_id, index, extension, width, height, title)
      end
    end

    items
  end

  # @param message_id String
  # @param no Integer
  # @param extension String
  # @param width Integer
  # @param height Integer
  # @param title String
  def initialize(message_id, no, extension, width, height, title)
    @message_id = message_id
    @no = no
    @extension = extension
    @width = width
    @height = height
    @title = title
  end

  def jpg?
    @extension == 'jpg'
  end

  def png?
    @extension == 'png'
  end

  def filename
    "#{@message_id}-#{@no}.#{@extension}"
  end

  def file_path
    "#{Settings.photo_bbs.top_directory}/#{filename}"
  end

  def thumbnail_filename
    "#{@message_id}-#{@no}-s.#{@extension}"
  end

  def thumbnail_file_path
    "#{Settings.photo_bbs.top_directory}/#{thumbnail_filename}"
  end

  def convert_to_jpg!
    return if jpg?

    image = Magick::Image.read(file_path).first
    thumbnail = Magick::Image.read(thumbnail_file_path).first
    @extension = 'jpg'
    image.write(file_path)
    thumbnail.write(thumbnail_file_path)
  end

  # @return Hash
  def photo_hash
    {
      title: @title,
      no: @no,
    }
  end
end
