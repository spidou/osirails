class AlterTableCheckings < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE checkings ADD CONSTRAINT date_employee_id_key UNIQUE (date, employee_id);"
    remove_column :checkings, :duration
    add_column :checkings, :overtime, :float
    add_column :checkings, :delay, :float
  end

  def self.down
    execute "ALTER TABLE checkings DROP CONSTRAINT date_employee_id_key;"
    add_column :checkings, :duration, :decimal
    remove_column :checkings, :overtime
    remove_column :checkings, :delay
  end
end
