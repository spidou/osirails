class CreateDeliveryInterventionsScheduledInstallers < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_scheduled_installers do |t|
      t.references :delivery_intervention, :scheduled_installer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_scheduled_installers
  end
end
