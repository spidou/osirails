class CreateEstimatesProductReferences < ActiveRecord::Migration
  def self.up
    create_table :estimates_product_references do |t|
      t.references :estimate
      t.references :product_reference
      t.integer :quantity
      t.float :unit_price
      t.timestamps
    end
  end

  def self.down
    drop_table :estimates_product_references
  end
end
