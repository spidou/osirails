class CreateEstablishments < ActiveRecord::Migration
  def self.up
    create_table :establishments do |t|
      t.references :establishment_type, :customer, :activity_sector_reference
      t.string     :name, :type, :siret_number
      t.boolean    :activated, :default => true
      t.integer    :logo_file_size
      t.datetime   :logo_updated_at
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :establishments
  end
end
