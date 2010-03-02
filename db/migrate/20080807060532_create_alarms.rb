class CreateAlarms < ActiveRecord::Migration
  def self.up
    create_table :alarms do |t|
      t.references :event
      t.string  :title, :description, :email_to, :action
      t.integer :do_alarm_before, :duration
      
      t.timestamps
    end
  end

  def self.down
    drop_table :alarms
  end
end
