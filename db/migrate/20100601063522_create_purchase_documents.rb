class CreatePurchaseDocuments < ActiveRecord::Migration
  def self.up
    create_table :purchase_documents do |t|
      t.string :photo_file_name, :photo_content_type
      t.integer :photo_file_size
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_documents
  end
end
