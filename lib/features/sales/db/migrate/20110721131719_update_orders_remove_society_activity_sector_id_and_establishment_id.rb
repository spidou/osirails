class UpdateOrdersRemoveSocietyActivitySectorIdAndEstablishmentId < ActiveRecord::Migration
  def self.up
    remove_column :orders, :society_activity_sector_id
    remove_column :orders, :establishment_id
  end

  def self.down
    add_column :orders, :society_activity_sector_id, :integer
    add_column :orders, :establishment_id, :integer
  end
end
