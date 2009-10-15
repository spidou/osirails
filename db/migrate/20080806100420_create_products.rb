class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :product_reference, :order
      t.string  :reference, :name, :dimensions
      t.text    :description
      t.float   :quantity
      
      t.timestamps
    end
    
    add_index :products, :reference, :unique => true
  end

  def self.down
    drop_table :products
  end
end
