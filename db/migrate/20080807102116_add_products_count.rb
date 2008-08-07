class AddProductsCount < ActiveRecord::Migration
  def self.up
        add_column :product_references, :products_count , :integer, :default => 0
  end

  def self.down
        remove_column :product_references, :products_count
  end
end
