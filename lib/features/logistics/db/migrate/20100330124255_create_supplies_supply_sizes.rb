class CreateSuppliesSupplySizes < ActiveRecord::Migration
  def self.up
    create_table :supplies_supply_sizes do |t|
      t.references :supply, :supply_size, :unit_measure
      t.string :value
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supplies_supply_sizes
  end
end
