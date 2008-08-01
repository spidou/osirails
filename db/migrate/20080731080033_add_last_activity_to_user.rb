class AddLastActivityToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_activity, :datetime
  end

  def self.down
    remove_column :users, :last_activity
  end
end
