class CreateGraphicItemSpoolItems < ActiveRecord::Migration
  def self.up
    create_table :graphic_item_spool_items do |t|
      t.references :user, :graphic_item
      t.string :path, :file_type
      t.timestamps
    end
  end

  def self.down
    drop_table :graphic_item_spool_items
  end
end
