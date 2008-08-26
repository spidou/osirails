class CreateCommodities < ActiveRecord::Migration
  def self.up
    create_table :commodities do |t|
      t.string :name
      t.integer :FOB_unit_price, :taxe_coefficient, :supplier_id,  :commodity_category_id,  :unit_mass, :measure
      t.integer :enable, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :commodities
  end
end
