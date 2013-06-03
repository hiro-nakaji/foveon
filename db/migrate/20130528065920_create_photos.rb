class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :entry_id, index: true
      t.string :entry_type, index: true
      t.string :storage_type
      t.string :title
      t.integer :no
      t.string :url
      t.string :thumbnail_url
      t.integer :thumbnail_width
      t.integer :thumbnail_height

      t.timestamps
    end
  end
end
