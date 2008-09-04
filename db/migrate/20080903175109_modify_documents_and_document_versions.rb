class ModifyDocumentsAndDocumentVersions < ActiveRecord::Migration
  def self.up
    remove_column :documents, :title
    add_column :document_versions, :name, :string    
    add_column :documents, :name, :string
  end

  def self.down
    remove_column :document_versions, :name
    remove_column :documents, :name
    add_column :documents, :title, :string
    
  end
end
