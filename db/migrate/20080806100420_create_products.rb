class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :product_reference, :order
      t.string  :reference, :name
      t.text    :description
      t.string  :dimensions
      t.float   :unit_price, :quantity, :discount, :vat
      t.integer :position
      
      t.timestamps
    end
    
    add_index :products, :reference, :unique => true
  end

  def self.down
    drop_table :products
  end
end
