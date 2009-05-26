class AddOriginalColumnsInQuotesProductReferences < ActiveRecord::Migration
  def self.up
    add_column :quotes_product_references, :original_description, :text
    add_column :quotes_product_references, :original_unit_price, :float
  end

  def self.down
    remove_column :quotes_product_references, :original_description
    remove_column :quotes_product_references, :original_unit_price
  end
end
