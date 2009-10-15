class CreateMimeTypeExtensions < ActiveRecord::Migration
  def self.up
    create_table :mime_type_extensions do |t|
      t.string :name, :mime_type_id
    end
  end

  def self.down
    drop_table :mime_type_extensions
  end
end
