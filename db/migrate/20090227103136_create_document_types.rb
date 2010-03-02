class CreateDocumentTypes < ActiveRecord::Migration
  def self.up
    create_table :document_types do |t|
      t.string :name
      t.string :title
      
      t.timestamps
    end
    
    add_index :document_types, :name, :unique => true
  end

  def self.down
    drop_table :document_types
  end
end
