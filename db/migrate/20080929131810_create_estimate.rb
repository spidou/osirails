class CreateEstimate < ActiveRecord::Migration
  def self.up
    create_table :estimates do |t|
      t.references :step_estimate
      t.boolean :validated
      
      t.timestamps
    end
  end

  def self.down
    drop_table :estimates
  end
end
