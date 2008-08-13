class CreateProductReferenceCategories < ActiveRecord::Migration
  def self.up
    create_table :product_reference_categories do |t|
      t.string :name
      t.integer :product_reference_category_id 

      t.timestamps
    end
  end

  def self.down
    drop_table :product_reference_categories
  end
end
