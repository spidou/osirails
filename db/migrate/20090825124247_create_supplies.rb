class CreateSupplies < ActiveRecord::Migration
  def self.up
    create_table :supplies do |t|
      t.references :supply_sub_category
      t.string  :type, :reference, :name, :packaging
      t.decimal :measure, :unit_mass, :threshold, :precision => 65 ,:scale => 18
      t.boolean :enabled,                         :default => true
      t.date    :disabled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supplies
  end
end
