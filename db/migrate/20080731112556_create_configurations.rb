class CreateConfigurations < ActiveRecord::Migration
  def self.up
    create_table :configurations do |t|
      t.string :name
      t.text :value
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :configurations
  end
end
