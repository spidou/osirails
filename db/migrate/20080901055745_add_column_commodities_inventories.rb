class AddColumnCommoditiesInventories < ActiveRecord::Migration
  def self.up
    add_column :commodities_inventories, :parent_commodity_category_id, :integer
    add_column :commodities_inventories, :commodity_category_id, :integer
    remove_column(:commodities_inventories, :quantity)
    add_column :commodities_inventories, :quantity, :float, :default => 0
    add_column :commodities_inventories, :commodity_category_name, :string
    add_column :commodities_inventories, :parent_commodity_category_name, :string
  end

  def self.down
    remove_column(:commodities_inventories, :parent_commodity_category_id)
    remove_column(:commodities_inventories, :commodity_category_id)
    remove_column(:commodities_inventories, :quantity)
    add_column :commodities_inventories, :quantity, :float
    remove_column(:commodities_inventories, :commodity_category_name)
    remove_column(:commodities_inventories, :parent_commodity_category_name)
    
  end
end
