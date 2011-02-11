class CreateSupplies < ActiveRecord::Migration
  def self.up
    create_table :supplies do |t|
      t.references :supply_type
      t.string    :type, :reference, :packaging
      t.decimal   :measure, :unit_mass, :threshold, :precision => 65 ,:scale => 18
      t.boolean   :enabled,                         :default => true
      t.datetime  :disabled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supplies
  end
end
