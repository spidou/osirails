class DeleteColumnsInEmployees < ActiveRecord::Migration
  def self.up
    remove_column :employees, :fix_phone
    remove_column :employees, :mobil_phone
    remove_column :employees, :fax
    remove_column :employees, :society_fix_phone
    remove_column :employees, :society_mobil_phone
    remove_column :employees, :society_fax
  end

  def self.down
    add_column :employees, :fix_phone, :integer
    add_column :employees, :mobil_phone, :integer
    add_column :employees, :fax, :integer
    add_column :employees, :society_fix_phone, :integer
    add_column :employees, :society_mobil_phone, :integer
    add_column :employees, :society_fax, :integer
  end
end
