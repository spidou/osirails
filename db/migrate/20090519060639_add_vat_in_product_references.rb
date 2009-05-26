class AddVatInProductReferences < ActiveRecord::Migration
  def self.up
    add_column :product_references, :vat, :float
  end

  def self.down
    remove_column :product_references, :vat
  end
end
