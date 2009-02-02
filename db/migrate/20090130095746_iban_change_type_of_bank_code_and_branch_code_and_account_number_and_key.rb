class IbanChangeTypeOfBankCodeAndBranchCodeAndAccountNumberAndKey < ActiveRecord::Migration
  def self.up
    remove_column(:ibans, :bank_code, :branch_code, :account_number, :key)
    add_column :ibans, :bank_code, :string
    add_column :ibans, :branch_code, :string
    add_column :ibans, :account_number, :string
    add_column :ibans, :key, :string
  end

  def self.down
    remove_column(:ibans, :bank_code, :branch_code, :account_number, :key)
    add_column :ibans, :bank_code, :integer
    add_column :ibans, :branch_code, :integer
    add_column :ibans, :account_number, :integer
    add_column :ibans, :key, :integer
  end
end
