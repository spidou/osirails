class CreateQuotesProductReferences < ActiveRecord::Migration
  def self.up
    create_table :quotes_product_references do |t|
      t.references :quote, :product_reference
      t.string  :name,        :original_name
      t.text    :description, :original_description
      t.float   :unit_price,  :original_unit_price
      t.float   :vat, :discount
      t.integer :quantity, :position
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quotes_product_references
  end
end
