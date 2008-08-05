class AddColumnEmployees < ActiveRecord::Migration
  def self.up
    add_column :employees, :qualification, :string
  end

  def self.down
    remove_column :employees, :qualification
  end
end
