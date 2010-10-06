class CreateQuotationRequestPurchaseRequestSupplies < ActiveRecord::Migration
  def self.up
    create_table :quotation_request_purchase_request_supplies do |t|
      t.references :quotation_request_supply, :purchase_request_supply
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotation_request_purchase_request_supplies
  end
end
