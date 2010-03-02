class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.references :product_reference, :order
      t.string    :reference, :name
      t.text      :description
      t.string    :dimensions
      t.decimal   :unit_price, :prizegiving, :precision => 65, :scale => 20
      t.float     :quantity, :vat
      t.integer   :position
      t.datetime  :cancelled_at
      
      t.timestamps
    end
    
    add_index :products, :reference, :unique => true
  end

  def self.down
    drop_table :products
  end
end
