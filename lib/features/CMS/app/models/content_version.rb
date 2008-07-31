class ContentVersion < ActiveRecord::Base
  
  belongs_to :content
  
  # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end
  
  # This method permit to delete create_at
  def created_at=(value)
    false
  end
  
    # This method permit to delete author
  def author=(value)
    false
  end
  
  # This method permit to delete lock_version
  def lock_version=(value)
    false
  end
  
  # This method return the next and previous StaticPageVersion
  def get_next
    
  end

  def get_previous
    
  end
end
