class CreateProductReferences < ActiveRecord::Migration
  def self.up
    create_table :product_references do |t|
      t.references :product_reference_category
      t.string  :reference, :name
      t.text    :description
      t.float   :production_cost_manpower, :production_time, :delivery_cost_manpower, :delivery_time, :vat
      t.boolean :enable,          :default => true
      t.integer :products_count,  :default => 0
      
      t.timestamps
    end
    
    add_index :product_references, :reference, :unique => true
  end

  def self.down
    drop_table :product_references
  end
end
