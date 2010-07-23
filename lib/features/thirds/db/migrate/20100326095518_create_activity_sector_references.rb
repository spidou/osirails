class CreateActivitySectorReferences < ActiveRecord::Migration
  def self.up
    create_table :activity_sector_references do |t|
      t.references :activity_sector, :custom_activity_sector
      t.string :code
    end
    
    add_index :activity_sector_references, :code, :unique => true
  end

  def self.down
    drop_table :activity_sector_references
  end
end
