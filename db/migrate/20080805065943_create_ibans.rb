class CreateIbans < ActiveRecord::Migration
  def self.up
    create_table :ibans do |t|
      t.references :has_iban, :polymorphic => true
      t.string :account_name, :bank_name, :bank_code, :branch_code, :account_number, :key
      
      t.timestamps
    end
  end

  def self.down
    drop_table :ibans
  end
end
