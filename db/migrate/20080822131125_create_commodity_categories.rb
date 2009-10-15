class CreateCommodityCategories < ActiveRecord::Migration
  def self.up
    create_table :commodity_categories do |t|
      t.references :commodity_category, :unit_measure
      t.string  :name
      t.integer :commodities_count, :default => 0
      t.boolean :enable,            :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :commodity_categories
  end
end
