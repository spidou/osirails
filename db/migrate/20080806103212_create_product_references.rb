class CreateProductReferences < ActiveRecord::Migration
  def self.up
    create_table :product_references do |t|
      t.string :name, :description, :production_cost_manpower, :production_time, :delivery_cost_manpower, :delivery_time, :information
      t.integer :product_reference_category_id
      t.integer :enable, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :product_references
  end
end
