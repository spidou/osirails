class UpdateCheckings < ActiveRecord::Migration
  def self.up
    change_table :checkings do |t|
      t.remove :user_id ,:absence_hours, :absence_minutes, :overtime_hours,
               :overtime_minutes, :overtime_comment, :cancelled      
      
      t.string   :absence_period
      t.datetime :morning_start ,:morning_end, :afternoon_start, :afternoon_end
      t.text     :morning_start_comment, :morning_end_comment, :afternoon_start_comment, :afternoon_end_comment
    end 
  end

  def self.down
    change_table :checkings do |t|
      t.remove :absence_period, :morning_start ,:morning_end, :afternoon_start, :afternoon_end,
               :morning_start_comment, :morning_end_comment, :afternoon_start_comment, :afternoon_end_comment
    
      t.references :user
      t.integer    :absence_hours, :absence_minutes, :overtime_hours, :overtime_minutes
      t.text       :overtime_comment
      t.boolean    :cancelled
    end
  end
end
