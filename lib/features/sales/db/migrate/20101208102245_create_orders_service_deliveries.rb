class CreateOrdersServiceDeliveries < ActiveRecord::Migration
  def self.up
    create_table :orders_service_deliveries do |t|
      t.references :order, :service_delivery
      t.string    :name
      t.text      :description
      t.float     :cost
      t.decimal   :margin, :prizegiving, :precision => 65, :scale => 20
      t.float     :quantity, :vat
      t.integer   :position
      t.boolean   :pro_rata_billing, :default => false
      t.datetime  :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :orders_service_deliveries
  end
end
