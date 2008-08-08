class CreateJobContracts < ActiveRecord::Migration
  def self.up
    create_table :job_contracts do |t|
      t.date :start_date,:end_date         
      t.references :employee
      t.references :employee_state
      t.references :job_contract_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :job_contracts
  end
end
