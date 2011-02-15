class CreateSupplyCategories < ActiveRecord::Migration
  def self.up
    create_table :supply_categories  do |t|
      t.references :supply_category, :unit_measure
      t.string    :type, :reference, :name
      t.integer   :supplies_count, :default => 0
      t.boolean   :enabled,        :default => true
      t.datetime  :disabled_at
      
      t.timestamps
    end
    
    add_index :supply_categories, :reference, :unique => true
    add_index :supply_categories, [ :name, :type, :supply_category_id ], :unique => true
  end

  def self.down
    drop_table :supply_categories
  end
end
