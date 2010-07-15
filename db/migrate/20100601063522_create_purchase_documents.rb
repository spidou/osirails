class CreatePurchaseDocuments < ActiveRecord::Migration
  def self.up
    create_table :purchase_documents do |t|
      t.string :purchase_documents_file_name, :purchase_documents_content_type
      t.integer :purchase_documents_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_documents
  end
end
