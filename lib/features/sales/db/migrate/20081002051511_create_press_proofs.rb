class CreatePressProofs < ActiveRecord::Migration
  def self.up
    create_table :press_proofs do |t|
      t.references :order, :end_product, :creator, :internal_actor, :revoked_by, :document_sending_method, :revoked_by
      t.string     :status, :reference
      t.integer    :signed_press_proof_file_size
      t.string     :signed_press_proof_file_name, :signed_press_proof_content_type
      t.text       :revoked_comment
      t.date       :confirmed_on, :signed_on, :sended_on, :revoked_on, :cancelled_on
      
      t.timestamps
    end
    
    add_index :press_proofs, :reference, :unique => true
  end

  def self.down
    drop_table :press_proofs
  end
end
