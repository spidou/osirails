class CreateCustomActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :custom_activity_sectors do |t|
      t.string :name
    end
    
    add_index :custom_activity_sectors, :name, :unique => true
  end

  def self.down
    drop_table :custom_activity_sectors
  end
end
