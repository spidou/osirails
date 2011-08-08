class Schedule < ActiveRecord::Base
  belongs_to :service
  
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
