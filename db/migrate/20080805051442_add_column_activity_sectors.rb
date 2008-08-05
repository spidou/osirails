class AddColumnActivitySectors < ActiveRecord::Migration
  def self.up
    add_column :activity_sectors, :activated, :boolean, :default => true
  end

  def self.down
    remove_column :activity_sectors, :activated
  end
end
