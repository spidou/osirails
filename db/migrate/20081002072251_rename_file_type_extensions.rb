class RenameFileTypeExtensions < ActiveRecord::Migration
  def self.up
    rename_table :file_type_extensions, :mime_type_extensions
    add_column :mime_type_extensions, :mime_type_id, :string
  end

  def self.down
    rename_table :mime_type_extensions, :file_type_extensions    
  end
end
