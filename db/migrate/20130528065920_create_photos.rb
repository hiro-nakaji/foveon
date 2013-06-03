class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :entry_id, index: true
      t.string :entry_type, index: true
      t.string :title
      t.integer :no
      t.string :photo_data

      t.timestamps
    end
  end
end
