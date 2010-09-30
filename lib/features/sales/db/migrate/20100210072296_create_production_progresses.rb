class CreateProductionProgresses < ActiveRecord::Migration
  def self.up
    create_table :production_progresses do |t|
      t.references :production_step, :product
      t.integer    :progression, :building_quantity, :built_quantity
      t.integer    :available_to_deliver_quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :production_progresses
  end
end
