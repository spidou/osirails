class AddLeaveRequestIdToLeaves < ActiveRecord::Migration
  def self.up
    add_column :leaves, :leave_request_id, :integer
  end

  def self.down
    remove_column :leaves, :leave_request_id, :integer
  end
end
