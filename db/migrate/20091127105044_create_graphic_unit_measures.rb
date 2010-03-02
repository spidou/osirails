class CreateGraphicUnitMeasures < ActiveRecord::Migration
  def self.up
    create_table :graphic_unit_measures do |t|
      t.string  :name, :symbol
      
      t.timestamps
    end
  end

  def self.down
    drop_table :graphic_unit_measures
  end
end
