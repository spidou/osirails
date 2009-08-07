class AddColumnDurationToTableLeaves < ActiveRecord::Migration
  def self.up
    add_column :leaves, :duration, :float
  end

  def self.down
    remove_column :leaves, :duration
  end
end
