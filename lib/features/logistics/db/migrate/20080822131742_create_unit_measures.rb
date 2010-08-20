class CreateUnitMeasures < ActiveRecord::Migration
  def self.up
    create_table :unit_measures do |t|
      t.string :name, :symbol
    end
    
    add_index :unit_measures, :name,  :unique => true
    add_index :unit_measures, :symbol, :unique => true
  end

  def self.down
    drop_table :unit_measures
  end
end
