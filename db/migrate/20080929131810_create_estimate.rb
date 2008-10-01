class CreateEstimate < ActiveRecord::Migration
  def self.up
    create_table :estimates do |t|
      t.references :step_estimate
      t.boolean :validated
      t.date :validity_date
      t.float :carriage_costs, :default => 0
      t.float :reduction, :default => 0
      t.float :account, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :estimates
  end
end
