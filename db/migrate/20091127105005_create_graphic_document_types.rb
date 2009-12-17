class CreateGraphicDocumentTypes < ActiveRecord::Migration
  def self.up
    create_table :graphic_document_types do |t|
      t.string  :name
      
      t.timestamps
    end
  end

  def self.down
    drop_table :graphic_document_types
  end
end
