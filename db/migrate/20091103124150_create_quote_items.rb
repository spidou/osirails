class CreateQuoteItems < ActiveRecord::Migration
  def self.up
    create_table :quote_items do |t|
      t.references :quote, :product
      t.string  :name
      t.text    :description
      t.string  :dimensions
      t.float   :unit_price, :quantity, :discount, :vat
      t.integer :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quote_items
  end
end
