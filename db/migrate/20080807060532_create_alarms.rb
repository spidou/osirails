class CreateAlarms < ActiveRecord::Migration
  def self.up
    create_table :alarms do |t|
      t.references :event
      t.string :action, :default => "DISPLAY"
      t.text :description
      t.integer :do_alarm_before, :default => "5"
      t.integer :duration
      t.string :title, :default => "Alarme"
      t.string :email_to

      t.timestamps
    end
  end

  def self.down
    drop_table :alarms
  end
end
