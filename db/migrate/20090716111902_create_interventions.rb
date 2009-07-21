class CreateInterventions < ActiveRecord::Migration
  def self.up
    create_table :interventions do |t|
      t.references :delivery_note
      t.boolean    :on_site
      t.datetime   :scheduled_delivery_at
      t.boolean    :delivered
      t.text       :comments
      
      t.timestamps
    end
  end

  def self.down
    drop_table :interventions
  end
end
