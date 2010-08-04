class CreatePurchaseDocuments < ActiveRecord::Migration
  def self.up
    create_table :purchase_documents do |t|
      t.string  :purchase_document_file_name, :purchase_document_content_type
      t.integer :purchase_document_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_documents
  end
end
