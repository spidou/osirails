class RemoveRetrievalFromLeaveRequests < ActiveRecord::Migration
  def self.up
    remove_column :leave_requests, :retrieval
  end

  def self.down
    add_column :leave_requests, :retrieval, :float
  end
end
