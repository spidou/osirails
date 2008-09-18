class CreateFacturationOrders < ActiveRecord::Migration
  def self.up
    create_table :facturation_orders do |t|
      t.references :order
      
      t.timestamps
    end
  end

  def self.down
    drop_table :facturation_orders
  end
end
