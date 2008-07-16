class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.string :name
      t.string :version
      t.text :dependencies
      t.text :conflicts
      t.boolean :installed, :default => false, :null => false
      t.boolean :activated, :default => false, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :features
  end
end
