class CreateEmployeeStates < ActiveRecord::Migration
  def self.up
    create_table :employee_states do |t|     
      t.string  :name
      t.boolean :active, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_states
  end
end
