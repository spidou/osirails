class CreateManufacturingSteps < ActiveRecord::Migration
  def self.up
    create_table :manufacturing_steps do |t|
      t.references :production_step
      t.string    :status
      t.datetime  :started_at, :finished_at
      t.date      :manufacturing_started_on, :manufacturing_finished_on
      
      t.timestamps
    end
  end

  def self.down
    drop_table :manufacturing_steps
  end
end
