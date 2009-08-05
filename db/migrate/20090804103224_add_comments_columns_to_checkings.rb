class AddCommentsColumnsToCheckings < ActiveRecord::Migration
  def self.up
    add_column :checkings, :morning_overtime_comment, :text
    add_column :checkings, :morning_delay_comment, :text
    add_column :checkings, :afternoon_overtime_comment, :text
    add_column :checkings, :afternoon_delay_comment, :text
    add_column :checkings, :absence_comment, :text
    add_column :checkings, :morning_overtime_hours, :integer
    add_column :checkings, :morning_overtime_minutes, :integer
    add_column :checkings, :morning_delay_hours, :integer
    add_column :checkings, :morning_delay_minutes, :integer
    add_column :checkings, :afternoon_overtime_hours, :integer
    add_column :checkings, :afternoon_overtime_minutes, :integer
    add_column :checkings, :afternoon_delay_hours, :integer
    add_column :checkings, :afternoon_delay_minutes, :integer
    remove_column :checkings, :morning_overtime
    remove_column :checkings, :morning_delay
    remove_column :checkings, :afternoon_overtime
    remove_column :checkings, :afternoon_delay
    remove_column :checkings, :comment
  end

  def self.down
    remove_column :checkings, :morning_overtime_comment
    remove_column :checkings, :morning_delay_comment
    remove_column :checkings, :afternoon_overtime_comment
    remove_column :checkings, :afternoon_delay_comment
    remove_column :checkings, :absence_comment
    remove_column :checkings, :morning_overtime_hours
    remove_column :checkings, :morning_overtime_minutes
    remove_column :checkings, :morning_delay_hours
    remove_column :checkings, :morning_delay_minutes
    remove_column :checkings, :afternoon_overtime_hours
    remove_column :checkings, :afternoon_overtime_minutes
    remove_column :checkings, :afternoon_delay_hours
    remove_column :checkings, :afternoon_delay_minutes
    add_column :checkings, :morning_overtime, :float
    add_column :checkings, :morning_delay, :float
    add_column :checkings, :afternoon_overtime, :float
    add_column :checkings, :afternoon_delay, :float
    add_column :checkings, :comment, :text
  end
end
