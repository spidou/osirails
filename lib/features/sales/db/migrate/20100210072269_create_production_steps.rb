class CreateProductionSteps < ActiveRecord::Migration
  def self.up
    create_table :production_steps do |t|
      t.references :pre_invoicing_step
      t.string    :status
      t.datetime  :started_at, :finished_at
      t.date      :begining_production_on, :ending_production_on
      
      t.timestamps
    end
  end

  def self.down
    drop_table :production_steps
  end
end
