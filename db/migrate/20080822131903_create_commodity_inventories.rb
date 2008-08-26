class CreateCommodityInventories < ActiveRecord::Migration
  def self.up
    create_table :commodity_inventories do |t|
    t.string :name, :unit_mass
    t.integer :FOB_unit_price, :taxe_coefficient, :quantity, :commodity_id, :inventory_id, :unit_measure_id, :supplier_id, :city_id
      t.timestamps
    end
  end

  def self.down
    drop_table :commodity_inventories
  end
end
