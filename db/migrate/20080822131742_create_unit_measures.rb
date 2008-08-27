class CreateUnitMeasures < ActiveRecord::Migration
  def self.up
    create_table :unit_measures do |t|
      t.string :name, :symbol
      t.timestamps
    end
  end

  def self.down
    drop_table :unit_measures
  end
end