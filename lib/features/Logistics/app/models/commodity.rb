class Commodity < ActiveRecord::Base

  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'commodity_category_id'
  
  # Relationship
  belongs_to :commodity_category, :counter_cache => true
  
  # Name Scope
  named_scope :activates, :conditions => {:enable => true}
  
end
