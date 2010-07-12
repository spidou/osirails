class CreateParcels < ActiveRecord::Migration
  def self.up
    create_table :parcels do |t|
      t.integer  :cancelled_by
      t.string   :reference, :status, :conveyance
      t.datetime :previsional_delivery_date, :shipped_at, :received_by_forwarder_at, :received_at, :cancelled_at
      t.boolean  :awaiting_pick_up

      t.timestamps
    end
  end

  def self.down
    drop_table :parcels
  end
end

