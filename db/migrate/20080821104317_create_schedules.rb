class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t| 
      t.references :service
      t.float   :morning_start, :morning_end, :afternoon_start, :afternoon_end
      t.string  :day
       
      t.timestamps
    end
    
  end

  def self.down
    drop_table :schedules
  end
end
