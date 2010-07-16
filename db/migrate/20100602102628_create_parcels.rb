class CreateParcels < ActiveRecord::Migration
  def self.up
    create_table :parcels do |t|
      t.references  :delivery_document
      t.integer     :cancelled_by
      t.string      :reference, :status, :conveyance
      t.text        :cancelled_comment
      t.datetime    :cancelled_at
      t.date         :previsional_delivery_date, :processing_by_supplier_since, :shipped_on, :received_by_forwarder_on, :received_on
      t.boolean     :awaiting_pick_up

      t.timestamps
    end
  end

  def self.down
    drop_table :parcels
  end
end

