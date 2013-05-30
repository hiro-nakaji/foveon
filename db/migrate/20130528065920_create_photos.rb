class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :entry_id, index: true
      t.string :entry_type, index: true
      t.string :title
      t.integer :no
      t.string :file_path
      t.string :thumbnail_file_path
      t.integer :thumbnail_width
      t.integer :thumbnail_height

      t.timestamps
    end
  end
end
