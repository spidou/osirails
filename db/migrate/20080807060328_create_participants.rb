class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.references :event
      t.text :name
      t.string :email
      t.references :employee
      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
