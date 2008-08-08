class AddEmployeesColumns < ActiveRecord::Migration
  def self.up
    add_column :employees, :civility, :string
    add_column :employees, :family_situation, :string
    add_column :employees, :birth_date, :date
    add_column :employees, :email, :string
    add_column :employees, :fix_phone, :integer
    add_column :employees, :mobil_phone, :integer
    add_column :employees, :fax, :integer
    add_column :employees, :society_email, :string
    add_column :employees, :society_fix_phone, :integer
    add_column :employees, :society_mobil_phone, :integer
    add_column :employees, :society_fax, :integer
    add_column :employees, :social_security, :string
  end

  def self.down
    remove_column :employees, :civility
    remove_column :employees, :family_situation
    remove_column :employees, :birth_date
    remove_column :employees, :email
    remove_column :employees, :fix_phone
    remove_column :employees, :mobil_phone
    remove_column :employees, :fax
    remove_column :employees, :society_email
    remove_column :employees, :society_fix_phone
    remove_column :employees, :society_mobil_phone
    remove_column :employees, :society_fax
    remove_column :employees, :social_security
  end
end
