class CreatePhotos < ActiveRecord::Migration
  def change
    enable_extension "hstore"

    create_table :photos do |t|
      t.integer :entry_id, index: true, null: false
      t.string :entry_type, index: true, null: false
      t.string :title
      t.integer :no, null: false
      t.string :photo_data, null: false
      t.hstore :exif

      t.timestamps
    end
  end
end
