class CreateOrderLog < ActiveRecord::Migration
  def self.up
    create_table :order_logs do |t|
      t.references :order, :user
      t.string :controller, :action
      t.text :parameters
      
      t.timestamps
    end
  end

  def self.down
    drop_table :order_logs
  end
end
