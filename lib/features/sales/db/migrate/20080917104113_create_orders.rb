class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.references :commercial, :user, :customer, :establishment, :society_activity_sector, :order_type, :approaching
      t.string     :title, :reference
      t.text       :customer_needs
      t.datetime   :closed_at
      t.date       :previsional_delivery, :quotation_deadline
      t.integer    :delivery_time
      
      t.timestamps
    end
    
    add_index :orders, :reference, :unique => true
  end

  def self.down
    drop_table :orders
  end
end
