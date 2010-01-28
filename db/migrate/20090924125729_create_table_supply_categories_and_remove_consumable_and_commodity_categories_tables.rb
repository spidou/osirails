class CreateTableSupplyCategoriesAndRemoveConsumableAndCommodityCategoriesTables < ActiveRecord::Migration
  def self.up
    create_table "supply_categories"  do |t|
      t.string   "type"
      t.string   "name"
      t.integer  "commodity_category_id"
      t.integer  "consumable_category_id"
      t.integer  "unit_measure_id"    
      t.integer  "commodities_count", :default => 0
      t.integer  "consumables_count", :default => 0
      t.boolean  "enable",            :default => true
      t.date     "disabled_at"
      t.timestamps
    end
    
    drop_table :consumable_categories
    drop_table :commodity_categories
  end

  def self.down
    drop_table :supply_categories
    
    create_table "commodity_categories"  do |t|
      t.string   "name"
      t.integer  "commodity_category_id" 
      t.integer  "unit_measure_id"       
      t.integer  "commodities_count", :default => 0
      t.boolean  "enable",            :default => true
      t.date     "disabled_at"
      t.timestamps
    end
    
    create_table "consumable_categories"  do |t|
      t.string   "name"
      t.integer  "consumable_category_id" 
      t.integer  "unit_measure_id"      
      t.integer  "consumables_count", :default => 0
      t.boolean  "enable",            :default => true
      t.date     "disabled_at"
      t.timestamps
    end
  end
end
