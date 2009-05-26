class AddUserIdInQuotes < ActiveRecord::Migration
  def self.up
    add_column :quotes, :user_id, :integer
  end

  def self.down
    remove_column :quotes, :user_id
  end
end
