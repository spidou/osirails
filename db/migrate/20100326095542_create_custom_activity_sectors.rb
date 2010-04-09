class CreateCustomActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :custom_activity_sectors do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :custom_activity_sectors
  end
end
