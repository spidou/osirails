class CreateSupplySizesUnitMeasures < ActiveRecord::Migration
  def self.up
    create_table :supply_sizes_unit_measures do |t|
      t.references :supply_size, :unit_measure
      t.integer :position
    end
    
    add_index :supply_sizes_unit_measures, [ :supply_size_id, :unit_measure_id ], :unique => true, :name => :index_supply_sizes_unit_measures
  end

  def self.down
    drop_table :supply_sizes_unit_measures
  end
end
