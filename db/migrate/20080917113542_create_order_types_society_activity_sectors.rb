class CreateOrderTypesSocietyActivitySectors < ActiveRecord::Migration
  def self.up
    create_table :order_types_society_activity_sectors, :id => false do |t|
      t.references :society_activity_sector, :order_type      
    end
  end

  def self.down
    drop_table :order_types_society_activity_sectors
  end
end
