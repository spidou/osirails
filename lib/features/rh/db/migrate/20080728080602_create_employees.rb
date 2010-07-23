class CreateEmployees < ActiveRecord::Migration
  def self.up
    create_table :employees do |t|
      t.references :user, :service, :civility, :family_situation
      t.string    :first_name, :last_name, :social_security_number, :qualification, :email, :society_email
      t.date      :birth_date
      t.string    :avatar_file_name, :avatar_content_type
      t.integer   :avatar_file_size
      t.datetime  :avatar_updated_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :employees
  end
end
