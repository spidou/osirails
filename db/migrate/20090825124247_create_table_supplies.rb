class CreateTableSupplies < ActiveRecord::Migration
  def self.up
    create_table :supplies do |t|
      t.string :name, :reference, :type
      t.decimal :measure, :unit_mass, :threshold, :precision => 65 ,:scale => 18
      t.integer :commodity_category_id, :consumable_category_id
      t.boolean :enable, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :supplies
  end
end
