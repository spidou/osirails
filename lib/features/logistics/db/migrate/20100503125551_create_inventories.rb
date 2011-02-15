class CreateInventories < ActiveRecord::Migration
  def self.up
    create_table :inventories do |t|
      t.string :supply_class
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :inventories
  end
end
