require 'spec_helper'

describe Photo do
  describe "validations" do
    it { should validate_presence_of(:entry_id) }
    it { should validate_presence_of(:entry_type) }
    it { should_not validate_presence_of(:title) }
    it { should validate_presence_of(:no) }
    it { should validate_presence_of(:photo_data) }
    it { should_not validate_presence_of(:exif) }
  end

  describe "extract_exif" do
    let!(:photo) { Photo.new }
    let!(:exif) {
      [
        ["ColorSpace", "1"],
        ["ComponentsConfiguration", "1, 2, 3, 0"],
        ["Compression", "6"],
        ["CustomRendered", "1"],
        ["DateTime", "2012:10:05 16:56:42"],
        ["DateTimeDigitized", "2012:10:05 16:56:42"],
        ["DateTimeOriginal", "2012:10:05 14:55:14"],
        ["ExifImageLength", "2640"],
        ["ExifImageWidth", "1760"],
        ["ExifOffset", "2847"],
        ["ExifVersion", "48, 50, 50, 48"],
        ["ExposureBiasValue", "-10/10"],
        ["ExposureMode", "2"],
        ["ExposureProgram", "3"],
        ["ExposureTime", "1/160"],
        ["FileSource", "3"],
        ["Flash", "0"],
        ["FlashPixVersion", "48, 49, 48, 48"],
        ["FNumber", "28/10"],
        ["FocalLength", "242/10"],
        ["FocalLengthIn35mmFilm", "41"],
        ["ImageUniqueID", "3031303033393933D2F46E5062626439"],
        ["ISOSpeedRatings", "50"],
        ["JPEGInterchangeFormat", "304"],
        ["JPEGInterchangeFormatLength", "2527"],
        ["Make", "SIGMA"],
        ["MakerNote", "83, 73, 71, 77, 65, 0, 0, 0, 1, 0, 25, 0, 2, 0, 2, 0, 8, 0, 0, 0, 233, 13, 0, 0, 3, 0, 2, 0, 7, 0, 0, 0, 241, 13, 0, 0, 4, 0, 2, 0, 3, 0, 0, 0, 72, 73, 0, 0, 5, 0, 2, 0, 3, 0, 0, 0, 77, 70, 0, 0, 6, 0, 2, 0, 2, 0, 0, 0, 77, 0, 0, 0, 7, 0, 2, 0, 9, 0, 0, 0, 248, 13, 0, 0, 8, 0, 2, 0, 2, 0, 0, 0, 65, 0, 0, 0, 9, 0, 2, 0, 2, 0, 0, 0, 56, 0, 0, 0, 10, 0, 2, 0, 5, 0, 0, 0, 1, 14, 0, 0, 11, 0, 2, 0, 5, 0, 0, 0, 6, 14, 0, 0, 12, 0, 2, 0, 10, 0, 0, 0, 11, 14, 0, 0, 13, 0, 2, 0, 10, 0, 0, 0, 21, 14, 0, 0, 14, 0, 2, 0, 10, 0, 0, 0, 31, 14, 0, 0, 15, 0, 2, 0, 10, 0, 0, 0, 41, 14, 0, 0, 16, 0, 2, 0, 10, 0, 0, 0, 51, 14, 0, 0, 17, 0, 2, 0, 10, 0, 0, 0, 61, 14, 0, 0, 18, 0, 2, 0, 10, 0, 0, 0, 71, 14, 0, 0, 20, 0, 2, 0, 5, 0, 0, 0, 81, 14, 0, 0, 21, 0, 2, 0, 20, 0, 0, 0, 86, 14, 0, 0, 22, 0, 2, 0, 8, 0, 0, 0, 106, 14, 0, 0, 23, 0, 2, 0, 11, 0, 0, 0, 114, 14, 0, 0, 24, 0, 2, 0, 27, 0, 0, 0, 125, 14, 0, 0, 25, 0, 2, 0, 2, 0, 0, 0, 32, 0, 0, 0, 26, 0, 2, 0, 20, 0, 0, 0, 152, 14, 0, 0, 27, 0, 2, 0, 12, 0, 0, 0, 172, 14, 0, 0, 0, 0, 0, 0, 49, 48, 48, 51, 57, 57, 51, 0, 83, 73, 78, 71, 76, 69, 0, 68, 97, 121, 108, 105, 103, 104, 116, 0, 50, 52, 46, 50, 0, 115, 82, 71, 66, 0, 69, 120, 112, 111, 58, 45, 48, 46, 51, 0, 67, 111, 110, 116, 58, 43, 48, 46, 51, 0, 83, 104, 97, 100, 58, 43, 48, 46, 48, 0, 72, 105, 103, 104, 58, 43, 48, 46, 48, 0, 83, 97, 116, 117, 58, 43, 48, 46, 48, 0, 83, 104, 97, 114, 58, 43, 48, 46, 51, 0, 70, 105, 108, 108, 58, 45, 48, 46, 51, 0, 67, 67, 58, 48, 0, 67, 117, 115, 116, 111, 109, 32, 83, 101, 116, 116, 105, 110, 103, 32, 77, 111, 100, 101, 0, 81, 117, 97, 108, 58, 49, 50, 0, 49, 46, 48, 49, 46, 48, 46, 48, 48, 50, 0, 83, 73, 71, 77, 65, 32, 80, 104, 111, 116, 111, 32, 80, 114, 111, 32, 52, 46, 50, 46, 50, 46, 48, 48, 48, 48, 0, 67, 104, 114, 111, 58, 45, 53, 51, 54, 56, 55, 48, 57, 49, 50, 46, 48, 48, 48, 0, 76"],
        ["MaxApertureValue", "76/10"],
        ["MeteringMode", "5"],
        ["Model", "SIGMA DP2S"],
        ["Orientation", "1"],
        ["ResolutionUnit", "2"],
        ["SceneCaptureType", "0"],
        ["SensingMethod", "2"],
        ["Software", "SIGMA Photo Pro 4.2.2.0000"],
        ["thumbnail:ResolutionUnit", "2"],
        ["thumbnail:XResolution", "180/1"],
        ["thumbnail:YResolution", "180/1"],
        ["WhiteBalance", "1"],
        ["XResolution", "180/1"],
        ["YCbCrPositioning", "2"],
        ["YResolution", "180/1"]
      ]
    }

    before do
      image = mock(Magick::Image)
      image.should_receive(:get_exif_by_entry).and_return(Marshal.load(Marshal.dump(exif)))
      Magick::Image.stub_chain(:read, :first).and_return(image)

      photo.extract_exif
    end

    it { photo.exif.count.should == exif.count }
    it { photo.exif.should == Hash[*exif.flatten] }
  end
end
