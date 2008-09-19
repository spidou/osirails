class MemorandumsService < ActiveRecord::Base

  # Relationships
  belongs_to :memorandum
  belongs_to :service 

  # Name Scope
  # named_scope :checked, :conditions => {:received => true, :memorandum_id => memorandum.id}
end
