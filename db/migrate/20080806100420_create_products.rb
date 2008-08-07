class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name, :description, :production_cost_manpower, :production_time, :delivery_cost_manpower, :delivery_time, :information
      t.integer :product_reference_id
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
