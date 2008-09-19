class Memorandum < ActiveRecord::Base

  # Relationships
  has_many :memorandums_services
  has_many :services, :through => :memorandums_services

  # This method permit to check if a memorandum is publish
  def can_published_memorandum?
    self.published_at.nil?
  end
  
  # This method permit to publish a memorandum
  def published_memorandum
    self.can_published_memorandum?
    self.published_at = Time.now
  end

end
