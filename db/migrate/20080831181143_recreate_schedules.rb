class RecreateSchedules < ActiveRecord::Migration
  def self.up
    drop_table :schedules
    create_table :schedules do |t| 
      t.float :morning_start,:morning_end,:afternoon_start,:afternoon_end
      t.string :day
      t.references :service
       
      t.timestamps
    end
    
  end

  def self.down
    drop_table :schedules
    create_table :schedules do |t| 
      t.integer :morning_start,:morning_end,:afternoon_start,:afternoon_end
      t.string :day
      t.references :service
       
      t.timestamps
    end
  end
end
