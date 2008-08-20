class RemoveColumnSalary < ActiveRecord::Migration
  def self.up 
    remove_column :salaries, :salary
    add_column :salaries, :salary, :float
    remove_column :premia, :value
    add_column :premia, :premium, :float
  end

  def self.down
    remove_column :salaries, :salary
    add_column :salaries, :salary, :integer
    remove_column :premia, :premium
    add_column :premia, :value, :integer
  end
end
