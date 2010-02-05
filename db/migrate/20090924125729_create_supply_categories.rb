class CreateSupplyCategories < ActiveRecord::Migration
  def self.up
    create_table :supply_categories  do |t|
      t.references :commodity_category, :consumable_category, :unit_measure
      t.string  :type, :name
      t.integer :commodities_count, :consumables_count, :default => 0
      t.boolean :enable,                                :default => true
      t.date    :disabled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supply_categories
  end
end
