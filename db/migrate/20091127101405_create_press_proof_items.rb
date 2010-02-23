class CreatePressProofItems < ActiveRecord::Migration
  def self.up
    create_table :press_proof_items do |t|
      t.references :press_proof, :graphic_item_version
      t.integerger   :position
      t.timestamps
    end
  end

  def self.down
    drop_table :press_proof_items
  end
end
