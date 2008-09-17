class CreateOrderTypesSocietyActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :order_types_society_activity_sectors do |t|
      t.references :society_activity_sector
      t.references :order_type
      
    end
  end

  def self.down
    drop_table :order_types_society_activity_sectors
  end
end
