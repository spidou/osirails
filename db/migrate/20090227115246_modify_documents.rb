class ModifyDocuments < ActiveRecord::Migration
  def self.up
    remove_column :documents, :extension, :file_type_id, :activated
    
    add_column :documents, :document_type_id, :integer
  end

  def self.down
    add_column :documents, :extension, :string
    add_column :documents, :file_type_id, :integer
    add_column :documents, :activated, :boolean
    
    remove_column :documents, :document_type_id
  end
end
