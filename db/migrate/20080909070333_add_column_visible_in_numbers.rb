class AddColumnVisibleInNumbers < ActiveRecord::Migration
  def self.up
    add_column :numbers, :visible, :boolean, :default => true
  end

  def self.down
    remove_column :numbers, :visible
  end
end
