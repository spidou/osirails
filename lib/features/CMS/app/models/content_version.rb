class ContentVersion < ActiveRecord::Base
  
  # Relationship
  belongs_to :content
  
  # This method permit to attribute a value to versioned_at
  def updated_at=(value)
    self.versioned_at = value
  end
  
    # This method permit to attribute a value to contributor
   def contributors=(value)
    self.contributor=(value)
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
  
end
