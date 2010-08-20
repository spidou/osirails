class CreateSupplierSupplies < ActiveRecord::Migration
  def self.up
    create_table :supplier_supplies do |t|
      t.references :supplier, :supply
      t.string  :supplier_reference
      t.integer :lead_time
      t.decimal :fob_unit_price, :taxes, :precision => 65 ,:scale => 18
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supplier_supplies
  end
end

