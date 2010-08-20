class CreateDeliveryInterventionsScheduledInstallationEquipments < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_scheduled_installation_equipments do |t|
      t.references :delivery_intervention, :scheduled_installation_equipment
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_scheduled_installation_equipments
  end
end
