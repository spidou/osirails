class CreateProductReferenceCategories < ActiveRecord::Migration
  def self.up
    create_table :product_reference_categories do |t|
      t.references :product_reference_category
      t.string  :name
      t.boolean :enable,                    :default => true
      t.integer :product_references_count,  :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :product_reference_categories
  end
end
