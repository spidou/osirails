class AddColumnActiveInEmployeeState < ActiveRecord::Migration
  def self.up
    add_column :employee_states, :active, :boolean
  end

  def self.down
    remove_column :employee_states, :active
  end
end
