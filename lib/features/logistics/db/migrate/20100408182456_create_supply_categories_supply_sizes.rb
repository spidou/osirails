class CreateSupplyCategoriesSupplySizes < ActiveRecord::Migration
  def self.up
    create_table :supply_categories_supply_sizes do |t|
      t.references :supply_sub_category, :supply_size, :unit_measure
      t.timestamps
    end
  end

  def self.down
    drop_table :supply_categories_supply_sizes
  end
end
