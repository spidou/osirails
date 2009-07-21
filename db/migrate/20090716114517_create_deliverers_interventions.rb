class CreateDeliverersInterventions < ActiveRecord::Migration
  def self.up
    create_table :deliverers_interventions do |t|
      t.references :deliverer, :intervention
    end
  end

  def self.down
    drop_table :deliverers_interventions
  end
end
