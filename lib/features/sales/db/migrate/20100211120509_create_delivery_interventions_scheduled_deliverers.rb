class CreateDeliveryInterventionsScheduledDeliverers < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_scheduled_deliverers do |t|
      t.references :delivery_intervention, :scheduled_deliverer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_scheduled_deliverers
  end
end
