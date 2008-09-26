class ChangeColumnTypeDescriptionInProductReference < ActiveRecord::Migration
  def self.up
    remove_column :product_references, :description
    add_column :product_references, :description, :text
  end

  def self.down
    remove_column :product_references, :description
    add_column :product_references, :description , :string
  end
end
