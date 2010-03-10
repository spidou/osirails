class CreateDeliveryInterventionsInstallers < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_installers do |t|
      t.references :delivery_intervention, :installer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_installers
  end
end
