class CreateFileTypesFileTypeExtensions < ActiveRecord::Migration
  def self.up
    create_table :file_types_file_type_extensions , :id => false do |t|
      t.integer :file_type_id, :file_type_extension_id
      t.timestamps
    end
  end

  def self.down
    drop_table :file_types_file_type_extensions
  end
end
