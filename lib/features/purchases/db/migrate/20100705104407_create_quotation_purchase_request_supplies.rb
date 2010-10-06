class CreateQuotationPurchaseRequestSupplies < ActiveRecord::Migration
  def self.up
    create_table :quotation_purchase_request_supplies do |t|
      t.references :quotation_supply, :purchase_request_supply
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotation_purchase_request_supplies
  end
end
