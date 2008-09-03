class CreateAlarms < ActiveRecord::Migration
  def self.up
    create_table :alarms do |t|
      t.references :event
      t.string :action
      t.text :description
      t.integer :do_alarm_before
      t.integer :duration
      t.string :title
      t.string :email_to

      t.timestamps
    end
  end

  def self.down
    drop_table :alarms
  end
end
