class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :type
      
      # product_references attributes
      t.references :product_reference_category
      t.integer :end_products_count, :default => 0
      
      # end_products attributes
      t.references :product_reference, :order
      t.float   :prizegiving, :unit_price
      t.integer :quantity, :position
      
      # common attributes
      t.string    :reference, :name, :dimensions
      t.text      :description
      t.float     :vat
      t.datetime  :cancelled_at
      
      t.timestamps
    end
    
    #add_index :products, [ :reference, :type ], :unique => true
  end

  def self.down
    drop_table :products
  end
end
