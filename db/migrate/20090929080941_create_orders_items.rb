class CreateOrdersItems < ActiveRecord::Migration
  def self.up
    create_table :orders_items do |t|
      t.references :order, :product_reference
      t.string :name, :original_name
      t.string :description, :original_description
      t.string :dimensions
      t.float  :quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :orders_items
  end
end
