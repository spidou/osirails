class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :title
      t.string :description
      t.string :extension
      t.references :file_type
      t.references :has_document, :polymorphic => true
      
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
