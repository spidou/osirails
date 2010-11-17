class CreateManufacturingProgresses < ActiveRecord::Migration
  def self.up
    create_table :manufacturing_progresses do |t|
      t.references :manufacturing_step, :end_product
      t.integer :progression
      t.integer :building_quantity, :built_quantity, :available_to_deliver_quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :manufacturing_progresses
  end
end
