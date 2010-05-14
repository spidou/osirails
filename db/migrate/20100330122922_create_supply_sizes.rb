class CreateSupplySizes < ActiveRecord::Migration
  def self.up
    create_table :supply_sizes do |t|
      t.string  :name, :short_name
      t.boolean :display_short_name, :accept_string
      t.integer :position
    end
    
    add_index :supply_sizes, :name, :unique => true
  end

  def self.down
    drop_table :supply_sizes
  end
end
