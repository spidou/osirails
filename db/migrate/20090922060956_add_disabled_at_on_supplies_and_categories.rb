class AddDisabledAtOnSuppliesAndCategories < ActiveRecord::Migration
  def self.up
    add_column :supplies, :disabled_at, :date
    add_column :commodity_categories, :disabled_at, :date
    add_column :consumable_categories, :disabled_at, :date
  end

  def self.down
    remove_column :supplies, :disabled_at
    remove_column :commodity_categories, :disabled_at
    remove_column :consumable_categories, :disabled_at
  end
end
