class CreateDeliveryNotes < ActiveRecord::Migration
  def self.up
    create_table :delivery_notes do |t|
      t.references :order, :creator
      t.string     :status
      t.date       :validated_on
      t.date       :invalidated_on
      t.date       :signed_on
      t.string     :attachment_file_name
      t.string     :attachment_content_type
      t.integer    :attachment_file_size
      t.string     :public_number
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_notes
  end
end
