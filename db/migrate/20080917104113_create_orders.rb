class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.string :title
      t.string :description
      t.integer :commercial_id
      t.references :user
      t.references :customer
      t.references :establishment
      t.references :activity_sector
      t.references :order_type
      t.datetime :closed_date
      t.datetime :previsional_start
      t.datetime :previsional_delivery
      
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
