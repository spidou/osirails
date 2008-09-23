class CreateStepDependencies < ActiveRecord::Migration
  def self.up
    create_table :step_dependencies do |t|
      t.integer :step_parent
      t.integer :step_child
    end
  end

  def self.down
    drop_table :step_dependencies
  end
end
