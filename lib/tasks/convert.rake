namespace :convert do

  desc "This converts Foveon Photo BBS data into The Foveon BBS"
  task photo: :environment do
    open(Settings.photo_bbs.data_path, "r") do |f|
      f.each do |line|
        next if line.empty?

        photo_message = FoveonPhotoBbs::Message.new(line)
        message = Message.find_by(message_type: 'photo', old_id: photo_message.id)

        next if message

        params = photo_message.message_hash
        message = Message.new(params)

        puts message.to_s

        if photo_message.parent_id.present?
          parent_message = Message.find_by(message_type: 'photo', old_id: photo_message.parent_id)
          message.parent_id = parent_message.id
        end

        if photo_message.photos.present?
          photo_message.photos.each do | photo |
            puts photo.filename

            unless photo.jpg?
              photo.convert_to_jpg!
            end

            photo = Photo.new(photo.photo_hash)
            message.photos << photo

            #begin
            #  exif_data = EXIFR::JPEG.new("#{Settings.photo_bbs.top_directory}/#{photo_message.id}-#{photo.index}.#{photo.extension}")
            #rescue EXIFR::MalformedJPEG => e
            #
            #rescue Errno::ENOENT => e
            #
            #ensure
            #end
          end
        end

        message.save!
      end
    end
  end

  desc "This converts Old Foveon BBS data into The Foveon BBS"
  task old_message: :environment do
    root_messages = OldMessage.where(parent_id: nil).order('lastupdate')

    root_messages.each do | old_parent_message |
      parent_message = Message.find_by(message_type: 'text', old_id: old_parent_message.id)

      next if parent_message

      puts old_parent_message.message_hash

      parent_message = Message.new(old_parent_message.message_hash)

      old_parent_message.children.each do | old_child_message |
        child_message = Message.new(old_child_message.message_hash)
        parent_message.children << child_message
      end

      parent_message.save!
    end
  end
end
