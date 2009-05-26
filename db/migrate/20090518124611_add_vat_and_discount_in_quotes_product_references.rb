class AddVatAndDiscountInQuotesProductReferences < ActiveRecord::Migration
  def self.up
    add_column :quotes_product_references, :vat, :float
    add_column :quotes_product_references, :discount, :float
  end

  def self.down
    remove_column :quotes_product_references, :vat
    remove_column :quotes_product_references, :discount
  end
end
