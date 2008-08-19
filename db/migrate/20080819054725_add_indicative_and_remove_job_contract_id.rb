class AddIndicativeAndRemoveJobContractId < ActiveRecord::Migration
  def self.up
    add_column :indicatives, :country, :string
    remove_column :job_contract_types, :job_contract_id
    remove_column :employee_states, :job_contract_id
  end

  def self.down
    remove_column :indicatives, :country
    add_column :job_contract_types, :job_contract_id, :integer
    add_column :employee_states, :job_contract_id, :integer
  end
end
