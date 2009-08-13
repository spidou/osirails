class AddCommentsColumnsToCheckings < ActiveRecord::Migration
  def self.up
    add_column :checkings, :absence_hours, :integer
    add_column :checkings, :absence_minutes, :integer
    add_column :checkings, :absence_comment, :text
    add_column :checkings, :overtime_hours, :integer
    add_column :checkings, :overtime_minutes, :integer
    add_column :checkings, :overtime_comment, :text
    remove_column :checkings, :absence 
    remove_column :checkings, :morning_overtime
    remove_column :checkings, :morning_delay
    remove_column :checkings, :afternoon_overtime
    remove_column :checkings, :afternoon_delay
    remove_column :checkings, :comment
  end

  def self.down
    remove_column :checkings, :absence_hours
    remove_column :checkings, :absence_minutes
    remove_column :checkings, :absence_comment
    remove_column :checkings, :overtime_hours
    remove_column :checkings, :overtime_minutes
    remove_column :checkings, :overtime_comment
    add_column :checkings, :morning_overtime, :float
    add_column :checkings, :morning_delay, :float
    add_column :checkings, :afternoon_overtime, :float
    add_column :checkings, :afternoon_delay, :float
    add_column :checkings, :comment, :text
  end
end
