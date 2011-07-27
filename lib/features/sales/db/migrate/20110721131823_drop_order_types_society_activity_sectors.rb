class DropOrderTypesSocietyActivitySectors < ActiveRecord::Migration
  def self.up
    drop_table :order_types_society_activity_sectors
  end

  def self.down
    create_table :order_types_society_activity_sectors, :id => false do |t|
      t.references :society_activity_sector, :order_type      
    end
    # data will not be recovered
  end
end
