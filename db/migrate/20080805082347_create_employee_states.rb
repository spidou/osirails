class CreateEmployeeStates < ActiveRecord::Migration
  def self.up
    create_table :employee_states do |t|     
      t.string :name
      t.references :job_contract
      
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_states
  end
end
