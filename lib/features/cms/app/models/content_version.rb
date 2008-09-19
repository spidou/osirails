class ContentVersion < ActiveRecord::Base
  
  # Relationship
  belongs_to :content
  belongs_to :contributor, :class_name => "User"
  
  # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end
  
    # This method permit to attribute a value to contributor
   def contributors=(value)
    self.contributor=(value)
  end
  
  # This method permit to unset create_at
  def created_at=(value)
    false
  end
  
    # This method permit to unset author
  def author=(value)
    false
  end
  
  # This method permit to unset lock_version
  def lock_version=(value)
    false
  end
  
end
