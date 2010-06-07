class CreateParcels < ActiveRecord::Migration
  def self.up
    create_table  :parcels do |t|
      t.datetime  :delivery_date
      t.string    :status
      t.string    :conveyance
      t.datetime  :shipped_at
      t.datetime  :received_at
      t.boolean   :state
      t.timestamps
    end
  end

  def self.down
    drop_table :parcels
  end
end
