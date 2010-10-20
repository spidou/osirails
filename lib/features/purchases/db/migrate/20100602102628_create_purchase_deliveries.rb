class CreatePurchaseDeliveries < ActiveRecord::Migration
  def self.up
    create_table    :purchase_deliveries do |t|
      t.references  :delivery_document, :cancelled_by, :forwarder, :departure, :arrival
      t.integer     :status
      t.string      :reference, :receive_conveyance, :ship_conveyance
      t.boolean     :awaiting_pick_up, :expected_recovery       
      t.date        :supplies_available_since, :previsional_delivery_date, :processing_by_supplier_since
      t.date        :shipped_on, :received_by_forwarder_on, :received_on
      t.text        :cancelled_comment
      t.datetime    :cancelled_at

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_deliveries
  end
end
