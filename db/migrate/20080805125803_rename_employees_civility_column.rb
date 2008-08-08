class RenameEmployeesCivilityColumn < ActiveRecord::Migration
  def self.up
    remove_column :employees, :civility
    add_column :employees, :civility_id, :integer
  end

  def self.down
    remove_column :employees, :civility_id
    add_column :employees, :civility, :string
  end
end
