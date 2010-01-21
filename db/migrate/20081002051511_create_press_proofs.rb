class CreatePressProofs < ActiveRecord::Migration
  def self.up
    create_table :press_proofs do |t|
      t.references :order, :product, :creator, :internal_actor, :revoked_by, :document_sending_method, :revoked_by
      t.integer    :signed_press_proof_file_size
      t.string     :status, :reference, :signed_press_proof_file_name, :signed_press_proof_content_type
      t.datetime   :signed_press_proof_updated_at
      t.text       :revoked_comment
      t.date       :confirmed_on, :signed_on, :sended_on, :revoked_on, :cancelled_on
      
      t.timestamps
    end
  end

  def self.down
    drop_table :press_proofs
  end
end
