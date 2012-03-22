class DeleteOrderLogs < ActiveRecord::Migration
  def self.up
    drop_table :order_logs
  end

  def self.down
    create_table :order_logs do |t|
      t.references :order, :user
      t.string :controller, :action
      t.text :parameters
      
      t.timestamps
    end
  end
end
