class CreateThirds < ActiveRecord::Migration
  def self.up
    create_table :thirds do |t|
      # common attributes
      t.references :legal_form, :creator
      t.string  :type, :name, :siret_number, :website
      t.boolean :activated, :default => true
      t.date    :company_created_at, :collaboration_started_at
      
      # supplier and subcontractor attributes
      t.references :activity_sector_reference
      
      # customer attributes
      t.references :factor, :customer_solvency, :customer_grade
      t.string  :logo_file_name, :logo_content_type
      t.integer :logo_file_size
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :thirds
  end
end
