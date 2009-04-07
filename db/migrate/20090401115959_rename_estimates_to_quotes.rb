class RenameEstimatesToQuotes < ActiveRecord::Migration
  def self.up
    rename_table :estimates, :quotes
    rename_table :estimates_product_references, :quotes_product_references
    rename_column :quotes_product_references, :estimate_id, :quote_id
  end

  def self.down
    rename_table :quotes, :estimates
    rename_table :quotes_product_references, :estimates_product_references
    rename_column :estimates_product_references, :quote_id, :estimate_id
  end
end
