class CreateDeliveryInterventionsDeliveryVehicles < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_delivery_vehicles do |t|
      t.references :delivery_intervention, :delivery_vehicle
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_delivery_vehicles
  end
end
