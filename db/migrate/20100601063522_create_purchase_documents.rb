class CreatePurchaseDocuments < ActiveRecord::Migration
  def self.up
    create_table :purchase_documents do |t|
      
      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_documents
  end
end
