class UpdateOrdersAddStatus < ActiveRecord::Migration
  def self.up
    remove_column :orders, :closed_at
    
    add_column :orders, :status, :string
    add_column :orders, :standby_on, :date
    add_column :orders, :discarded_on, :date
    add_column :orders, :completed_on, :date
  end

  def self.down
    add_column :orders, :closed_at, :datetime
    
    remove_column :orders, :status
    remove_column :orders, :standby_on
    remove_column :orders, :discarded_on
    remove_column :orders, :completed_on
  end
end
