class CreateParcels < ActiveRecord::Migration
  def self.up
    create_table    :parcels do |t|
      t.references  :purchase_delivery
      t.float       :mass, :volume
      t.string      :dimension, :reference
      t.text        :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_payments
  end
end
