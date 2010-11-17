class CreateDeliverySteps < ActiveRecord::Migration
  def self.up
    create_table :delivery_steps do |t|
      t.references :production_step
      t.string    :status
      t.datetime  :started_at
      t.datetime  :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_steps
  end
end
