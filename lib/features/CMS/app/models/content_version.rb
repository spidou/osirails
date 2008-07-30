class ContentVersion < ActiveRecord::Base
  
  belongs_to :content
  
  # This method return the next and previous StaticPageVersion
  def get_next
    
  end

  def get_previous
    
  end
end