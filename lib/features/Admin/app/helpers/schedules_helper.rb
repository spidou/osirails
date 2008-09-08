module SchedulesHelper

  def time_select(name,value)
    html =  select(name,value, ["Brut","Net"], :selected => "Brut")
  end
  

end
