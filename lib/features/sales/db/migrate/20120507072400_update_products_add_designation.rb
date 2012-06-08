class UpdateProductsAddDesignation < ActiveRecord::Migration
  def self.up
    add_column :products, :designation, :string
  end

  def self.down
    remove_column :products, :designation
  end
end
