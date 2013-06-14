FactoryGirl.define do
  factory :photo1, class: Photo do
    title 'photo1'
    no 1
    photo_data { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'photo', 'SDIM1153.jpg')) }

  end

  factory :photo2, class: Photo do
    title 'photo2'
    no 1
    photo_data { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'photo', 'SDIM1153.jpg')) }
  end
end