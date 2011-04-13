class CreateJobContracts < ActiveRecord::Migration
  def self.up
    create_table :job_contracts do |t|
      t.references :employee, :job_contract_type
      t.date :start_date, :end_date, :departure
      t.text :departure_description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :job_contracts
  end
end
