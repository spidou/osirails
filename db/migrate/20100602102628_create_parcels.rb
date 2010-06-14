class CreateParcels < ActiveRecord::Migration
  def self.up
    create_table  :parcels do |t|
      t.string    :conveyance
      t.string    :status
      
      t.boolean   :state

      t.datetime  :previsional_delivary_date
      t.datetime  :shipped_at
      t.datetime  :received_at
      t.datetime  :delivery_date
      t.timestamps
    end
  end

  def self.down
    drop_table :parcels
  end
end
