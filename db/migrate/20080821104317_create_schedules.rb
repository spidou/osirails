class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t| 
      t.integer :morning_start,:morning_end,:afternoon_start,:afternoon_end
      t.string :day
      t.references :service
       
      t.timestamps
    end
    
    ["Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"].each do |day|
      Schedule.create :morning_start => 7 ,:morning_end => 12 ,:afternoon_start => ,:afternoon_end => ,:day => day
    end
  end

  def self.down
    drop_table :schedules
  end
end
