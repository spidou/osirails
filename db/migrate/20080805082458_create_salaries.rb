class CreateSalaries < ActiveRecord::Migration
  def self.up
    create_table :salaries do |t|
      t.references :job_contract
      t.float :gross_amount
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :salaries
  end
end
