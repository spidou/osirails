class CreateCommodities < ActiveRecord::Migration
  def self.up
    create_table :commodities do |t|
      t.references :supplier,  :commodity_category
      t.string  :name
      t.float   :fob_unit_price, :taxe_coefficient, :measure, :unit_mass
      t.boolean :enable, :default => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :commodities
  end
end
