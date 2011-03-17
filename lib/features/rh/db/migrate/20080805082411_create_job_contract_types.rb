class CreateJobContractTypes < ActiveRecord::Migration
  def self.up
    create_table :job_contract_types do |t|     
      t.string  :name
      t.boolean :limited, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :job_contract_types
  end
end
