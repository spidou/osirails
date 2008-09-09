class ChangeTypeColumnProducts < ActiveRecord::Migration
  def self.up
    remove_column :product_references, :enable
    add_column :product_references, :enable, :boolean, :default => true
    add_column :product_reference_categories, :enable, :boolean, :default => true
  end

  def self.down
    remove_column :product_reference_categories, :enable
    remove_column :product_references, :enable
    add_column :product_references, :enable, :integer, :default => 1
  end
end
