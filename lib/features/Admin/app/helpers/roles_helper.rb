module RolesHelper
  
  # to get a preview  of the string
  def preview(string,length)
    string.length>length and !string.nil? ? string[0,length] +" (...)" : string 
  end
  
end
