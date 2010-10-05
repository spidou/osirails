class CreateQuotationSupplies < ActiveRecord::Migration
  def self.up
    create_table :quotation_supplies do |t|
      t.references  :quotation, :supply
      t.integer     :position
      t.float       :taxes, :unit_price, :prizegiving, :quantity
      t.string      :designation, :supplier_reference, :supplier_designation
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotation_supplies
  end
end

