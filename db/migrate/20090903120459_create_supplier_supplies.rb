class CreateSupplierSupplies < ActiveRecord::Migration
  def self.up
    create_table :supplier_supplies do |t|
      t.string :reference, :name
      t.integer :supply_id, :supplier_id, :lead_time
      t.decimal :fob_unit_price, :tax_coefficient, :precision => 65 ,:scale => 18
      t.timestamps
    end
  end

  def self.down
    drop_table :supplier_supplies
  end
end

