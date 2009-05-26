class AddPositionInQuotesProductReferences < ActiveRecord::Migration
  def self.up
    add_column :quotes_product_references, :position, :integer
  end

  def self.down
    remove_column :quotes_product_references, :position
  end
end
