class AddNameColumnInQuotesProductReferences < ActiveRecord::Migration
  def self.up
    add_column :quotes_product_references, :name, :string
    add_column :quotes_product_references, :original_name, :string
  end

  def self.down
    remove_column :quotes_product_references, :name
    remove_column :quotes_product_references, :original_name
  end
end
