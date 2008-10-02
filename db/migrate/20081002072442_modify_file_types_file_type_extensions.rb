class ModifyFileTypesFileTypeExtensions < ActiveRecord::Migration
  def self.up
    rename_table :file_types_file_type_extensions, :file_types_mime_types
    rename_column :file_types_mime_types, :file_type_extension_id, :mime_type_id
  end

  def self.down
    rename_table :file_types_mime_types, :file_types_file_type_extensions
    rename_column :file_types_file_type_extensions, :mime_type_id, :file_type_extension_id
  end
end
