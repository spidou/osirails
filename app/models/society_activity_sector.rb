class SocietyActivitySector < ActiveRecord::Base  
  named_scope :activates, :conditions => {:activated => true}, :order => "name"
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name] = "Nom :"
end
