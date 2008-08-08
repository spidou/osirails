class CreateIbans < ActiveRecord::Migration
  def self.up
    create_table :ibans do |t|
      t.integer :bank_code, :teller_code, :account_number, :key
      t.string :holder_name
      t.references :has_iban, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :ibans
  end
end
