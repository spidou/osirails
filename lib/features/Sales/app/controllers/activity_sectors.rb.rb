class ActivitySectorsController < ApplicationController
  
  auto_complete_for :activity_sectors, :name
     # Autocomplete
  def auto_complete_for_activity_sectors_name
    puts "tes"
    puts params[:activity_sectors][:name]
#    auto_complete_responder_for_name(params[:activity_sectors][:name])
  end
  
  def auto_complete_responder_for_name(value)
    ActivitySectors.find(:all)
#    @sectors = ActivitySectors.find(:all, 
#      :conditions => [ 'LOWER(name) LIKE ?',
#        '%' + value.downcase + '%'], 
#      :order => 'name ASC',
#      :limit => 8)
#    render :partial => 'addresses/cities_name'
  end
end