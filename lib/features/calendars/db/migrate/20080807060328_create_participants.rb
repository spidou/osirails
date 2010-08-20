class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.references :event, :employee
      t.text    :name
      t.string  :email
      
      t.timestamps
    end
  end

  def self.down
    drop_table :participants
  end
end
