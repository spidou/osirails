class CreateEmployeSensitiveDatas < ActiveRecord::Migration
  def self.up
    create_table :employee_sensitive_datas do |t|
      t.references :family_situation, :employee
      t.string     :social_security_number, :email
      t.date       :birth_date
      
      t.timestamps
    end
  end

  def self.down
    drop_table :employee_sensitive_datas
  end
end
