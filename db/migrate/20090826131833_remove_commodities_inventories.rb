class RemoveCommoditiesInventories < ActiveRecord::Migration
  def self.up
    drop_table :commodities_inventories 
  end

  def self.down
    create_table :commodities_inventories do |t|
      t.string :name, :commodity_category_name, :parent_commodity_category_name
      t.float :quantity, :default => 0
      t.float :fob_unit_price, :taxe_coefficient, :measure, :unit_mass
      t.integer :commodity_id, :inventory_id, :unit_measure_id, :supplier_id, :parent_commodity_category_id, :commodity_category_id
      t.timestamps
    end
  end
end
