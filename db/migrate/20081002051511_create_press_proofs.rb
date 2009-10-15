class CreatePressProofs < ActiveRecord::Migration
  def self.up
    create_table :press_proofs do |t|
      t.references :graphic_conception_step
      t.string :status
      t.string :transmission_mode
      
      t.timestamps
    end
  end

  def self.down
    drop_table :press_proofs
  end
end
