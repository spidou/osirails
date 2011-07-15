class Schedule < ActiveRecord::Base
  belongs_to :service
  
  # Search Plugin
  has_search_index :except_attributes => [:created_at, :updated_at, :service_id, :id]

  def works_morning?
    !morning_start.nil? && !morning_end.nil?
  end

  def works_afternoon?
    !afternoon_start.nil? && !afternoon_end.nil?
  end

  def works_whole_day?
    !morning_start.nil? && !morning_end.nil? && !afternoon_start.nil? && !afternoon_end.nil?
  end
  
  def works_today?
   works_morning? || works_afternoon?
  end

 def scheduled_morning_hours
    return works_morning? ? morning_end - morning_start :  0
 end

  def scheduled_afternoon_hours
    return works_afternoon? ? afternoon_end - afternoon_start : 0
  end

  def  scheduled_total_hours
    return works_today? ?  scheduled_morning_hours + scheduled_afternoon_hours : 0
  end

end


#a = Leave.create(:employee_id => 1 , :leave_type_id => 1 , :leave_request_id => 1 , :start_date => Date.today - 20 , :end_date => Date.today - 18, :start_half => false, :end_half => false, :duration => 2)

#a = Leave.create(:employee_id => 1 , :leave_type_id => 1 , :leave_request_id => 1 , :start_date => Date.today - 16 , :end_date => Date.today - 14, :start_half => true, :end_half => false, :duration => 2)

#a = Leave.create(:employee_id => 1 , :leave_type_id => 1 , :leave_request_id => 1 , :start_date => Date.today - 12 , :end_date => Date.today - 10, :start_half => false, :end_half => true, :duration => 2)


#a = Leave.create(:employee_id => 1 , :leave_type_id => 1 , :leave_request_id => 1 , :start_date => Date.today - 8 , :end_date => Date.today - 6, :start_half => true, :end_half => true, :duration => 2)


#a = Leave.create(:employee_id => 1 , :leave_type_id => 1 , :leave_request_id => 1 , :start_date => Date.today - 6 , :end_date => Date.today - 4, :start_half => true, :end_half => true, :duration => 2)

#a = Schedule.create(:service_id => 1 , :morning_start=> 8.5 , :morning_end => 12 , :afternoon_start => 13 , :afternoon_end => 16.5, :day => "lundi")
#a = Schedule.create(:service_id => 1 , :morning_start=> nil , :morning_end => nil , :afternoon_start => 13 , :afternoon_end => 16.5, :day => "vendredi")
#a = Schedule.create(:service_id => 1 , :morning_start=> 8.5 , :morning_end => 12 , :afternoon_start => nil , :afternoon_end => nil , :day => "samedi")
#a = Schedule.create(:service_id => 1 , :morning_start=> nil , :morning_end => nil , :afternoon_start => nil , :afternoon_end => nil , :day => "dimanche")






#a = Checking.new(:employee_id => 1 , :date=> Date.today , :absence_comment => nil, :absence_period => nil ,:morning_start_comment => nil , :morning_end_comment=> nil, :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today  - 1 , :absence_comment => nil, :absence_period => nil ,:morning_start_comment => nil , :morning_end_comment=> nil, :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today + 1 , :absence_comment => nil, :absence_period => nil ,:morning_start_comment => nil , :morning_end_comment=> nil, :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today  , :absence_comment => "ok", :absence_period => "morning" ,:morning_start_comment => nil , :morning_end_comment=> nil, :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today  , :absence_comment => "ok", :absence_period => "afternoon" ,:morning_start_comment => nil , :morning_end_comment=> nil, :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today  , :absence_comment => "ok", :absence_period => "whole_day" ,:morning_start_comment => nil , :morning_end_comment=> nil, :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today  , :absence_comment => "ok", :absence_period => "morning" ,:morning_start_comment => "ok" , :morning_end_comment=> "ok" , :afternoon_start_comment => "ok" , :afternoon_end_comment => "ok")

#a = Checking.new(:employee_id => 1 , :date=> Date.today , :absence_comment => nil, :absence_period => nil ,:morning_start_comment => "ok" , :morning_end_comment=> nil , :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today , :absence_comment => nil, :absence_period => nil ,:morning_start_comment => "ok" , :morning_end_comment=> "ok" , :afternoon_start_comment => nil , :afternoon_end_comment => nil)

#a = Checking.new(:employee_id => 1 , :date=> Date.today  , :absence_comment => nil, :absence_period => nil ,:morning_start_comment => "ok" , :morning_end_comment=> "ok" , :afternoon_start_comment => "ok" , :afternoon_end_comment => "ok")

