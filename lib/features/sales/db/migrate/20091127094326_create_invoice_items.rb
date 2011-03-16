class CreateInvoiceItems < ActiveRecord::Migration
  def self.up
    create_table :invoice_items do |t|
      t.references :invoice, :invoiceable
      t.string  :invoiceable_type
      t.integer :position
      t.float   :quantity
      
      # only for free_items (with no end_product)
      t.string  :name
      t.text    :description
      t.decimal :unit_price, :precision => 65, :scale => 20
      t.float   :vat
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_items
  end
end
