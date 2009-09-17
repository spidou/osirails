class AddNewColumnsToLeaveRequests < ActiveRecord::Migration
  def self.up
    add_column :leave_requests, :duration, :float
    add_column :leave_requests, :retrieval, :float
  end

  def self.down
    remove_column :leave_requests, :duration
    remove_column :leave_requests, :retrieval
  end
end
