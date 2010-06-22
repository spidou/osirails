class CreateParcels < ActiveRecord::Migration
  def self.up
    create_table :parcels do |t|
      t.string   :reference, :status, :conveyance
      t.datetime :previsional_delivery_date, :shipped_at, :received_at, :recovered_at, :delivery_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :parcels
  end
end
