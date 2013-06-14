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
end
