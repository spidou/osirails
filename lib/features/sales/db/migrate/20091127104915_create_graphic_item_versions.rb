class CreateGraphicItemVersions < ActiveRecord::Migration
  def self.up
    create_table :graphic_item_versions do |t|
      t.references :graphic_item
      t.string  :source_file_name, :image_file_name, :source_content_type, :image_content_type
      t.integer :source_file_size, :image_file_size
      t.boolean :is_current_version, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :graphic_item_versions
  end
end
