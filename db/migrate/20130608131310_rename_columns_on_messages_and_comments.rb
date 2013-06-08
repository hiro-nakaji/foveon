class RenameColumnsOnMessagesAndComments < ActiveRecord::Migration
  def change
    rename_column :messages, :remote_address, :remote_addr
    rename_column :messages, :browser, :user_agent
    rename_column :comments, :remote_address, :remote_addr
    rename_column :comments, :browser, :user_agent
  end
end
