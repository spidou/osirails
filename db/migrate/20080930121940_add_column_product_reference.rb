class AddColumnProductReference < ActiveRecord::Migration
  def self.up
    add_column :product_references, :reference, :string, :unique => true
  end

  def self.down
    remove_column :product_references, :reference
  end
end
