class CreateCommercialOrders < ActiveRecord::Migration
  def self.up
    create_table :commercial_orders do |t|
      t.references :order
      t.references :step
      t.string :type
      t.string :status
      t.datetime :start_date
      t.datetime :end_date
      
    end
  end

  def self.down
    drop_table :commercial_orders
  end
end
