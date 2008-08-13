class DeleteIdColumn  < ActiveRecord::Migration
  def self.up
    remove_column :employees_services, :id
    remove_column :employees_jobs, :id
  end

  def self.down
    add_column :employees_services, :id, :integer
    add_column :employees_jobs, :id, :integer
  end
end
