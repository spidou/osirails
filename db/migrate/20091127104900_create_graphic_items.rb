class CreateGraphicItems < ActiveRecord::Migration
  def self.up
    create_table :graphic_items do |t|
      t.references :creator, :graphic_unit_measure, :graphic_document_type, :mockup_type, :order, :press_proof, :product
      t.string  :type, :name, :reference
      t.text    :type, :description
      t.boolean :cancelled
      
      t.timestamps
    end
  end

  def self.down
    drop_table :graphic_items
  end
end
