class RenameEmployeesFamilySituation < ActiveRecord::Migration
  def self.up
    remove_column :employees, :family_situation
    add_column :employees, :family_situation_id, :integer
  end

  def self.down
    remove_column :employees, :family_situation_id
    add_column :employees, :family_situation, :string
  end
end
