class CreateSupplies < ActiveRecord::Migration
  def self.up
    create_table :supplies do |t|
      t.references :commodity_category, :consumable_category
      t.string  :name, :reference, :type
      t.decimal :measure, :unit_mass, :threshold, :precision => 65 ,:scale => 18
      t.boolean :enable, :default => true
      t.date    :disabled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supplies
  end
end
