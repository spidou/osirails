class AddColumnCancelledToCheckings < ActiveRecord::Migration
  def self.up
    add_column :checkings, :cancelled, :boolean
  end

  def self.down
    remove_column :checking, :cancelled
  end
end
