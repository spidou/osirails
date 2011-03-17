class CreateEstablishments < ActiveRecord::Migration
  def self.up
    create_table :establishments do |t|
      t.references :establishment_type, :customer, :activity_sector_reference
      t.string     :name, :type, :siret_number
      t.boolean    :activated, :default => true
      t.boolean    :hidden, :default => false
      t.string     :logo_file_name, :logo_content_type
      t.integer    :logo_file_size
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :establishments
  end
end
