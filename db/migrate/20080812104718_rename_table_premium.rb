class RenameTablePremium < ActiveRecord::Migration
  def self.up
    rename_table(:premiums, :premia)
  end

  def self.down
    rename_table(:premia, :premiums)
  end
end
