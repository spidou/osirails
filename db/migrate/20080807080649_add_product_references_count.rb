class AddProductReferencesCount < ActiveRecord::Migration
  def self.up
    add_column :product_reference_categories, :product_references_count , :integer, :default => 0

  end

  def self.down
    remove_column :product_reference_categories, :product_references_count
  end
end