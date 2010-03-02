class CreateFileTypesMimeTypes < ActiveRecord::Migration
  def self.up
    create_table :file_types_mime_types , :id => false do |t|
      t.references :file_type, :mime_type
      t.timestamps
    end
  end

  def self.down
    drop_table :file_types_mime_types
  end
end
