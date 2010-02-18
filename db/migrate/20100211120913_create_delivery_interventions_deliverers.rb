class CreateDeliveryInterventionsDeliverers < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions_deliverers do |t|
      t.references :delivery_intervention, :deliverer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions_deliverers
  end
end
