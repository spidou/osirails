class AddNewColumnsToCheckings < ActiveRecord::Migration
  def self.up
    remove_column :checkings, :overtime
    remove_column :checkings, :delay
    add_column :checkings, :morning_overtime, :float
    add_column :checkings, :afternoon_overtime, :float
    add_column :checkings, :morning_delay, :float
    add_column :checkings, :afternoon_delay, :float
    add_column :checkings, :absence, :integer
  end

  def self.down
    add_column :checkings, :overtime, :float
    add_column :checkings, :delay, :float
    remove_column :checkings, :morning_overtime
    remove_column :checkings, :afternoon_overtime
    remove_column :checkings, :morning_delay
    remove_column :checkings, :afternoon_delay
    remove_column :checkings, :absence
  end
end
