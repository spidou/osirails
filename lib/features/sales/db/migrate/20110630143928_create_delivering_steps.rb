class CreateDeliveringSteps < ActiveRecord::Migration
  def self.up
    create_table :delivering_steps do |t|
      t.references :order
      t.string    :status
      t.datetime  :started_at
      t.datetime  :finished_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivering_steps
  end
end
