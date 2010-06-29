class CreateSalaries < ActiveRecord::Migration
  def self.up
    create_table :salaries do |t|
      t.references :job_contract
      t.decimal :gross_amount, :precision => 65, :scale => 20
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :salaries
  end
end
