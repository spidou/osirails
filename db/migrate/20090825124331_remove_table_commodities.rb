class RemoveTableCommodities < ActiveRecord::Migration
  def self.up
    drop_table :commodities
  end

  def self.down
    create_table :commodities do |t|
      t.string :name
      t.float :fob_unit_price, :taxe_coefficient, :measure, :unit_mass
      t.integer :supplier_id,  :commodity_category_id
      t.boolean :enable, :default => true
      t.timestamps
    end
  end
end
