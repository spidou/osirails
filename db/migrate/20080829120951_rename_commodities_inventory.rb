class RenameCommoditiesInventory < ActiveRecord::Migration
  def self.up
    rename_table(:commodity_inventories, :commodities_inventories)
  end

  def self.down
    rename_table(:commodities_inventories, :commodity_inventories)
  end
end
