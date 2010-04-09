class CreateActivitySectorReferences < ActiveRecord::Migration
  def self.up
    create_table :activity_sector_references do |t|
      t.string :code
      t.references :activity_sector, :custom_activity_sector
    end
  end

  def self.down
    drop_table :activity_sector_references
  end
end
