class CreateUnitMeasures < ActiveRecord::Migration
  def self.up
    create_table :unit_measures do |t|
      t.string :name, :symbol
      t.timestamps
    end
    
    UnitMeasure.create :name => "Millimètre", :symbol => "mm"
    UnitMeasure.create :name => "Centimètre", :symbol => "cm"
    UnitMeasure.create :name => "Décimètre", :symbol => "dm"
    UnitMeasure.create :name => "Mètre", :symbol => "m"
    
    UnitMeasure.create :name => "Millimètre carré", :symbol => "mm²"
    UnitMeasure.create :name => "Centimètretre carré", :symbol => "cm²"
    UnitMeasure.create :name => "Décimètre carré", :symbol => "dm²"
    UnitMeasure.create :name => "Mètre carré", :symbol => "m²"
    
    UnitMeasure.create :name => "Millimètre cube", :symbol => "mm³"
    UnitMeasure.create :name => "Centimètretre cube", :symbol => "cm³"
    UnitMeasure.create :name => "Décimètre cube", :symbol => "dm³"
    UnitMeasure.create :name => "Mètre cube", :symbol => "m³"
    
    UnitMeasure.create :name => "Millilitre", :symbol => "ml"
    UnitMeasure.create :name => "Centilitre", :symbol => "cl"
    UnitMeasure.create :name => "Décilitre", :symbol => "dl"
    UnitMeasure.create :name => "Litre", :symbol => "l"
    
  end

  def self.down
    drop_table :unit_measures
  end
end