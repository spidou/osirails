class ChangeTypeInProductReferences < ActiveRecord::Migration
  def self.up
    change_column :product_references, :production_cost_manpower, :float
    change_column :product_references, :production_time, :float
    change_column :product_references, :delivery_cost_manpower, :float
    change_column :product_references, :delivery_time, :float
  end

  def self.down
    change_column :product_references, :production_cost_manpower, :string
    change_column :product_references, :production_time, :string
    change_column :product_references, :delivery_cost_manpower, :string
    change_column :product_references, :delivery_time, :string
  end
end
