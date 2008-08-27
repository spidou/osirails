class RenameColumnsInIbans < ActiveRecord::Migration
  def self.up
    rename_column :ibans, :teller_code, :branch_code
    rename_column :ibans, :holder_name, :account_name
    add_column :ibans, :bank_name, :string

  end

  def self.down
    remove_column  :ibans, :bank_name
    rename_column :ibans, :branch_code, :teller_code
    rename_column :ibans, :account_name, :holder_name
  end
end
