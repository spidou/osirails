class CreateDeliveryInterventionsScheduledDeliveryVehicles < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_scheduled_delivery_vehicles do |t|
      t.references :delivery_intervention, :scheduled_delivery_vehicle
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_scheduled_delivery_vehicles
  end
end
