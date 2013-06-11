class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.string :password
      t.string :mail
      t.string :homepage, limit: 512
      t.text :content, null: false
      t.string :remote_address
      t.string :browser, limit: 512
      t.integer :old_id, limit: 8
      t.string :message_type, default: nil
      t.references :message, index: true

      t.timestamps
    end
  end
end
