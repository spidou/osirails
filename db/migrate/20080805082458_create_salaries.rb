class CreateSalaries < ActiveRecord::Migration
  def self.up
    create_table :salaries do |t|     
      t.integer :salary
      t.references :job_contract
      
      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :salaries
  end
end
