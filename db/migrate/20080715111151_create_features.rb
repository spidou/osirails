class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.string  :name, :title, :version
      t.text    :dependencies, :conflicts
      t.boolean :installed, :activated, :default => false, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :features
  end
end
