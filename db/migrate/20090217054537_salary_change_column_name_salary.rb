class SalaryChangeColumnNameSalary < ActiveRecord::Migration
  def self.up
    rename_column :salaries, :salary, :gross_amount
  end

  def self.down
    rename_column :salaries, :gross_amount, :salary
  end
end
