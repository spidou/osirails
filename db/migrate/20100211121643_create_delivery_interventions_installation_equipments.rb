class CreateDeliveryInterventionsInstallationEquipments < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_installation_equipments do |t|
      t.references :delivery_intervention, :installation_equipment
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_installation_equipments
  end
end
