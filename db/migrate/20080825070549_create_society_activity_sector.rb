class CreateSocietyActivitySector < ActiveRecord::Migration
  def self.up
    create_table :society_activity_sectors do |t|
      t.string :name
      t.boolean :activated, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :society_activity_sectors
  end
end
