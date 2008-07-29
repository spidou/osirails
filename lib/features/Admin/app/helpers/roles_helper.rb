module RolesHelper
  
  # to get a preview  of the string
  def preview(string,length)
    string.length>length ? string[0,length] +" (...)" : string 
  end
  
end
