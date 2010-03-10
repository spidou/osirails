class CreateStepDependencies < ActiveRecord::Migration
  def self.up
    create_table :step_dependencies, :id => false do |t|
      t.references :step
      t.integer :step_dependent
      
      t.timestamps
    end
  end

  def self.down
    drop_table :step_dependencies
  end
end
