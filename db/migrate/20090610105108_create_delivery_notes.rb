class CreateDeliveryNotes < ActiveRecord::Migration
  def self.up
    create_table :delivery_notes do |t|
      t.references :order, :creator, :delivery_note_type
      t.string    :status, :reference
      t.string    :attachment_file_name, :attachment_content_type
      t.integer   :attachment_file_size
      t.date      :published_on, :signed_on
      t.datetime  :confirmed_at, :cancelled_at
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_notes
  end
end
