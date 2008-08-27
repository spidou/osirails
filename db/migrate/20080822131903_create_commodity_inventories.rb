class CreateCommodityInventories < ActiveRecord::Migration
  def self.up
    create_table :commodity_inventories do |t|
      t.string :name
      t.float :fob_unit_price, :taxe_coefficient, :price, :measure, :unit_mass, :quantity
      t.integer :commodity_id, :inventory_id, :unit_measure_id, :supplier_id
      t.timestamps
    end
  end

  def self.down
    drop_table :commodity_inventories
  end
end
