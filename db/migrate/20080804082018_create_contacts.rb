class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.references :contact_type
      t.string  :first_name, :last_name, :job, :email, :gender
      t.string  :avatar_file_name, :avatar_content_type
      t.integer :avatar_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
