class RenameColumnSocialSecurityIntoEmployees < ActiveRecord::Migration
  def self.up
    rename_column :employees, :social_security, :social_security_number
  end

  def self.down
    rename_column :employees, :social_security_number, :social_security
  end
end
