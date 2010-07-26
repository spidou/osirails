class CreateActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :activity_sectors do |t|
      t.string :type, :name
    end
    
    add_index :activity_sectors, [ :name, :type ], :unique => true
  end

  def self.down
    drop_table :activity_sectors
  end
end
