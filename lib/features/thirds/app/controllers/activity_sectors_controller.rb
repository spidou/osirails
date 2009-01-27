class ActivitySectorsController < ApplicationController

#  def auto_complete_for_activity_sector_name
#    auto_complete_responder_for_name(params[:value])
#  end
#  
#  def auto_complete_responder_for_name(value)
#    @activity_sectors = ActivitySector.find(:all, 
#      :conditions => [ 'LOWER(name) LIKE ?',
#        '%' + value.downcase + '%'], 
#      :order => 'name ASC',
#      :limit => 8)
#    render :partial => 'thirds/activity_sectors'
#  end
  
end
