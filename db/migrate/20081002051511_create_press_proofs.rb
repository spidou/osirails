class CreatePressProofs < ActiveRecord::Migration
  def self.up
    create_table :press_proofs do |t|
      t.string :status
      t.string :transmission_mode
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :press_proofs
  end
end
