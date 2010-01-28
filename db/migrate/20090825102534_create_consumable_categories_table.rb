class CreateConsumableCategoriesTable < ActiveRecord::Migration
  def self.up
    create_table :consumable_categories do |t|
      t.string :name
      t.integer :consumable_category_id, :unit_measure_id
      t.integer :consumables_count, :default => 0
      t.boolean :enable, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :consumable_categories
  end
end
