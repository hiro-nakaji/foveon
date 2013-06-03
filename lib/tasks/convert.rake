namespace :convert do

  desc "This converts Foveon Photo BBS data into The Foveon BBS"
  task photo: :environment do
    open(Settings.photo_bbs.data_path, "r") do |f|
      f.each do |line|
        next if line.empty?

        photo_message = FoveonPhotoBbs::Message.new(line)

        if photo_message.parent_id.empty?
          create_message_from_photo_message(photo_message)
        else
          create_comment_from_photo_message(photo_message)
        end
      end
    end
  end

  desc "This converts Old Foveon BBS data into The Foveon BBS"
  task old_message: :environment do
    root_messages = OldMessage.where(parent_id: nil).order('lastupdate')

    root_messages.each do | old_parent_message |
      message = Message.find_by(message_type: 'text', old_id: old_parent_message.id)

      next if message

      puts old_parent_message.message_hash

      message = Message.new(old_parent_message.message_hash)

      old_parent_message.children.each do | old_child_message |
        comment = Comment.new(old_child_message.message_hash)
        message.comments << comment
      end

      message.save!
    end
  end

  def create_message_from_photo_message(photo_message)
    message = Message.find_by(message_type: 'photo', old_id: photo_message.id)
    return if message

    params = photo_message.message_hash
    message = Message.new(params)

    add_photos(photo_message, message)

    message.save!
  end

  def create_comment_from_photo_message(photo_message)
    comment = Comment.find_by(message_type: 'photo', old_id: photo_message.id)
    return if comment

    params = photo_message.message_hash
    message = Message.find_by(message_type: 'photo', old_id: photo_message.parent_id)
    params[:message] = message
    comment = Comment.new(params)

    add_photos(photo_message, comment)

    comment.save!
  end

  def add_photos(photo_message, entry)
    if photo_message.photos.present?
      photo_message.photos.each do | photo |
        unless photo.jpg?
          photo.convert_to_jpg!
        end

        new_photo = Photo.new(photo.photo_hash)
        new_photo.photo_data  = File.open("#{Settings.photo_bbs.top_directory}/#{photo_message.id}-#{photo.no}.#{photo.extension}")
        entry.photos << new_photo
      end
    end
  end
end
