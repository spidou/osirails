class CreateQuotationRequestSupplies < ActiveRecord::Migration
  def self.up
    create_table :quotation_request_supplies do |t|
      t.references  :supply, :quotation_request
      t.integer     :quantity, :position
      t.string      :designation, :supplier_reference, :supplier_designation
      t.boolean     :comment_line
      t.text        :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotation_request_supplies
  end
end
