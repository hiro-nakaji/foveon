class Photo < ActiveRecord::Base
  belongs_to :entry, polymorphic: true

  mount_uploader :photo_data, PhotoDataUploader

  before_save :extract_exif, if: :photo_data_changed?

  def formatted_exif
    data = Hash.new
    data[:Make] = self.exif['Make'] if self.exif['Make']
    data[:Model] = self.exif['Model'] if self.exif['Model']
    data[:DateTimeOriginal] = self.exif['DateTimeOriginal'] if self.exif['DateTimeOriginal']
    data[:ExposureBiasValue] = "#{exif['ExposureBiasValue']}" if self.exif['ExposureBiasValue']
    data[:ExposureMode] = I18n.t("exif.ExposureMode.#{self.exif['ExposureMode']}") if self.exif['ExposureMode']
    data[:ExposureProgram] = I18n.t("exif.ExposureProgram.#{self.exif['ExposureProgram']}") if self.exif['ExposureProgram']
    data[:ExposureTime] = self.exif['ExposureTime'] if self.exif['ExposureTime']
    data[:FNumber] = self.exif['FNumber'] if self.exif['FNumber']
    data[:FocalLength] = self.exif['FocalLength'] if self.exif['FocalLength']
    data[:ISOSpeedRatings] = self.exif['ISOSpeedRatings'] if self.exif['ISOSpeedRatings']
    data[:Flash] = I18n.t("exif.Flash.#{self.exif['Flash']}") if self.exif['Flash']
    data
  end

  def extract_exif
    tmp_exif = Hash.new
    begin
      image = Magick::Image.read(photo_data.current_path).first
      image.get_exif_by_entry.each do |datas|
        key = datas.shift
        tmp_exif[key] = datas.present? ? datas.first : nil
      end
      self.exif = tmp_exif
    rescue => e
      Rails.logger.error(e.message)
      raise e
    end
  end


  #Make
  #Model
  #DateTimeOriginal
  #ExposureBiasValue
  #ExposureMode  (0: 'オート', 1: 'マニュアル', 2: 'Auto Bracket')
  #ExposureProgram 1: マニュアル 2: ノーマル 3: 絞り優先 4: シャッター優先
  #ExposureTime
  #FNumber 28/10 焦点/F値
  #FocalLength, 242/10 焦点距離/F値
  #ISOSpeedRatings
  #Flash
end
