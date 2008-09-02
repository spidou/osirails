class CreateFileTypeExtensions < ActiveRecord::Migration
  def self.up
    create_table :file_type_extensions do |t|
      t.string :name
      
    end
  end

  def self.down
    drop_table :file_type_extensions
  end
end
