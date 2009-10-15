class CreateCommoditiesInventories < ActiveRecord::Migration
  def self.up
    create_table :commodities_inventories do |t|
      t.references :commodity, :inventory, :parent_commodity_category, :commodity_category,
                   :unit_measure, :supplier
      t.string  :name, :commodity_category_name, :parent_commodity_category_name
      t.float   :fob_unit_price, :taxe_coefficient, :measure, :unit_mass
      t.float   :quantity, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :commodities_inventories
  end
end
