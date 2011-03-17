class CreateQuoteItems < ActiveRecord::Migration
  def self.up
    create_table :quote_items do |t|
      t.references :quote, :quotable
      t.string  :quotable_type, :name
      t.text    :description
      t.string  :dimensions
      t.decimal :unit_price, :prizegiving, :precision => 65, :scale => 20
      t.float   :quantity, :vat
      t.integer :position
      t.boolean :pro_rata_billing, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quote_items
  end
end
