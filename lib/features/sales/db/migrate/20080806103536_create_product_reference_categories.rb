class CreateProductReferenceCategories < ActiveRecord::Migration
  def self.up
    create_table :product_reference_categories do |t|
      # product_reference_sub_categories attributes
      t.references :product_reference_category
      t.integer   :product_references_count, :default => 0
      
      # common attributes
      t.string    :type, :reference, :name
      t.datetime  :cancelled_at
      
      t.timestamps
    end
    
    add_index :product_reference_categories, :reference, :unique => true
    add_index :product_reference_categories, [ :name, :type, :product_reference_category_id ], :unique => true,
                                                                                               :name => :index_product_reference_categories_on_name
  end

  def self.down
    drop_table :product_reference_categories
  end
end
