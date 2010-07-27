class CreateDeliveryInterventions < ActiveRecord::Migration
  def self.up
    create_table :delivery_interventions do |t|
      t.references  :delivery_note
      
      ## scheduled
      t.references  :scheduled_internal_actor, :scheduled_delivery_subcontractor, :scheduled_installation_subcontractor
      t.datetime    :scheduled_delivery_at
      t.integer     :scheduled_intervention_hours, :scheduled_intervention_minutes
      t.text        :scheduled_delivery_vehicles_rental, :scheduled_installation_equipments_rental
      
      t.boolean     :delivered, :postponed
      
      ## reality
      t.references  :internal_actor, :delivery_subcontractor, :installation_subcontractor
      t.datetime    :delivery_at
      t.integer     :intervention_hours, :intervention_minutes
      t.text        :delivery_vehicles_rental, :installation_equipments_rental
      
      t.text        :comments # if delivery fail
      t.string      :report_file_name, :report_content_type
      t.integer     :report_file_size
      t.references  :cancelled_by
      t.datetime    :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_interventions
  end
end
