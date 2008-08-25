class CreateActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :activity_sectors do |t|
      t.string :name

      t.timestamps
    end
    
    ActivitySector.create :name => "Privé"
    ActivitySector.create :name => "Public"
    
  end

  def self.down
    drop_table :activity_sectors
  end
end
