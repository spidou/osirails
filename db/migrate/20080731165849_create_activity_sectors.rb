class CreateActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :activity_sectors do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :activity_sectors
  end
end
