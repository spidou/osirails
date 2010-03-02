class CreateActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :activity_sectors do |t|
      t.string :name
      t.boolean :activated, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :activity_sectors
  end
end
