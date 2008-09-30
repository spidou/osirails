class AddColumnLimitedInJobContractType < ActiveRecord::Migration
  def self.up
    add_column :job_contract_types, :limited, :boolean 
  end

  def self.down
    remove_column :job_contract_types, :limited
  end
end
