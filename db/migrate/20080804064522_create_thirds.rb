class CreateThirds < ActiveRecord::Migration
  def self.up
    create_table :thirds do |t|
      # common attributes
      t.references :legal_form, :activity_sector_reference, :creator
      t.date    :company_created_at, :collaboration_start
      t.string  :type, :name, :siret_number, :website, :logo_file_name, :logo_content_type
      t.integer :note, :default => 0
      t.integer :logo_file_size
      t.boolean :activated, :default => true
      t.datetime :logo_updated_at
      
      # customer attributes
      t.references :factor, :customer_solvency, :customer_grade
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :thirds
  end
end
