class AlterTableLeaves < ActiveRecord::Migration
  def self.up
    add_column :leaves, :leave_type_id , :integer
  end

  def self.down
    remove_column :leaves, :leave_type_id
  end
end
