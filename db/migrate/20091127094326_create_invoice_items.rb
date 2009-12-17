class CreateInvoiceItems < ActiveRecord::Migration
  def self.up
    create_table :invoice_items do |t|
      t.references :invoice, :product
      t.float   :quantity, :discount
      t.integer :position
      
      # only for free_items (with no product)
      t.string :name
      t.text   :description
      t.float  :unit_price, :vat
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_items
  end
end
