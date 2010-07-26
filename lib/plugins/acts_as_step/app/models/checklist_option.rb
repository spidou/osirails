class ChecklistOption < ActiveRecord::Base
  acts_as_tree :order => :position
  acts_as_list :scope => :parent
  
  belongs_to :checklist
  
  has_many :checklist_options_order_types
  has_many :order_types, :through => :checklist_options_order_types
end
