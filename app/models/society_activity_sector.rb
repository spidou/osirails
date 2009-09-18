class SocietyActivitySector < ActiveRecord::Base  
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
  
  has_search_index :only_attributes => [:name]
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
  
  # for pagination : number of instances by index page
  SOCIETY_ACTIVITY_SECTORS_PER_PAGE = 15
end
