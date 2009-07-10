class ChangeAssociationBetweenUserAndEmployees < ActiveRecord::Migration
  def self.up
    remove_column :users, :employee_id
    add_column    :employees, :user_id, :integer
  end

  def self.down
    add_column    :users, :employee_id, :integer
    remove_column :employees, :user_id
  end
end
