class Photo < ActiveRecord::Base
  belongs_to :entry, polymorphic: true

  #ActionDispatch::Http::UploadedFile
  @image

  validate :check_image

  before_save :process_image
  after_destroy :destroy_image

  def image
    @image
  end

  def image=(value)
    attribute_will_change!('image') if image != value
    @image = value
  end

  def image_changed?
    changed.include?('image')
  end

  private

  #@param filename String
  def self.thumbnail_filename(filename)
    File.basename(filename, '.*') + '_s' + File.extname(filename)
  end

  # @param uploaded_file ActionDispatch::Http::UploadedFile
  # @return Magick::Image
  def self.create_thumbnail(uploaded_file)
    image = Magick::Image.read(uploaded_file.tempfile.path).first
    image.resize_to_fit!(Settings.foveon_bbs.thumbnail_width)
    image
  end

  def check_image
    Rails.logger.info("check_image:#{@image}")
    return unless @image

    unless /^image\/(jpg|jpeg|png|gif)/ =~ @image.content_type
      self.errors.add(:image, :invalid, content_type: @image.content_type)
    end
  end

  def process_image
    Rails.logger.info("process_image:#{@image}")
    return unless @image

    #@tempfile, original_filename, content_type, headers
    self.storage_type = Settings.foveon_bbs.photo_storage_type
    self.title = @image.original_filename if self.title.empty?

    if /^image\/(jpg|jpeg)/ =~ @image.content_type
      #@TODO analyze Exif
    end

    thumbnail_image = self.class.create_thumbnail(@image)
    self.thumbnail_width = thumbnail_image.columns
    self.thumbnail_height = thumbnail_image.rows

    case Settings.foveon_bbs.photo_storage_type
    when :local
      photo_dir = Settings.foveon_bbs.photo_local_directory
      photo_top = Settings.foveon_bbs.photo_top
      dir_name = SecureRandom.uuid
      Dir.mkdir("#{photo_dir}/#{dir_name}")

      filename = @image.original_filename
      path = "#{photo_dir}/#{dir_name}/#{filename}"
      FileUtils.cp @image.tempfile.path, path

      thumbnail_filename = self.class.thumbnail_filename(filename)
      thumbnail_path = "#{photo_dir}/#{dir_name}/#{thumbnail_filename}"
      thumbnail_image.write(thumbnail_path)

      destroy_image if persisted?

      self.url = "#{photo_top}/#{dir_name}/#{filename}"
      self.thumbnail_url = "#{photo_top}/#{dir_name}/#{thumbnail_filename}"
    end
  end

  def destroy_image
    case Settings.foveon_bbs.photo_storage_type
    when :local
      FileUtils.rm(local_path)
      FileUtils.rm(local_thumbnail_path)
      Dir::rmdir(File.dirname(local_path))
    end
  end

  def local_path
    Settings.foveon_bbs.photo_local_directory +
      self.url.sub(Settings.foveon_bbs.photo_top, '')
  end

  def local_thumbnail_path
    Settings.foveon_bbs.photo_local_directory +
      self.thumbnail_url.sub(Settings.foveon_bbs.photo_top, '')
  end
end
