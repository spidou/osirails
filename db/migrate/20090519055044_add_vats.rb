class AddVats < ActiveRecord::Migration
  def self.up
    create_table :vats do |t|
      t.string :name
      t.float :rate
      t.integer :position
    end
  end

  def self.down
    drop_table :vats
  end
end
