class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.references :event
      t.string :has_type
      t.integer :has_id
      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
