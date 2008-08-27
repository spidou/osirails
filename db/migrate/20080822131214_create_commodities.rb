class CreateCommodities < ActiveRecord::Migration
  def self.up
    create_table :commodities do |t|
      t.string :name
      t.float :fob_unit_price, :taxe_coefficient, :price, :measure, :unit_mass
      t.integer :supplier_id,  :commodity_category_id
      t.integer :enable, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :commodities
  end
end