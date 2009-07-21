class ChangeActivitySectorIdToSocietyActivitySectorIdInOrders < ActiveRecord::Migration
  def self.up
    rename_column :orders, :activity_sector_id, :society_activity_sector_id
  end

  def self.down
    rename_column :orders, :society_activity_sector_id, :activity_sector_id
  end
end
