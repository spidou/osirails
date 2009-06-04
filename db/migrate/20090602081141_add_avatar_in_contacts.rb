class AddAvatarInContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :avatar_file_name, :string
    add_column :contacts, :avatar_content_type, :string
    add_column :contacts, :avatar_file_size, :integer
  end

  def self.down
    remove_column :contacts, :avatar_file_name
    remove_column :contacts, :avatar_content_type
    remove_column :contacts, :avatar_file_size
  end
end
