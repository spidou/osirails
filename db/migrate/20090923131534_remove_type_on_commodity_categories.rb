class RemoveTypeOnCommodityCategories < ActiveRecord::Migration
  def self.up
    remove_column :commodity_categories, :type
  end

  def self.down
    add_column :commodity_categories, :type
  end
end
