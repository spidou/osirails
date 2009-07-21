class CreateDeliveryNotes < ActiveRecord::Migration
  def self.up
    create_table :delivery_notes do |t|
      t.references :delivery_step, :user
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
    
    create_table :delivery_notes_quotes_product_references do |t|
      t.references :delivery_note, :quotes_product_reference, :report_type
      t.integer    :quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delivery_notes
    drop_table :delivery_notes_quotes_product_references
  end
end
