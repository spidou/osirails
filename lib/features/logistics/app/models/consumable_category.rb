class ConsumableCategory < SupplyCategory
  has_permissions :as_business_object, :class_methods => [:list, :view, :add, :edit, :delete, :disable, :reactivate]
  
  # Plugin
  acts_as_tree :order => :name, :foreign_key => 'consumable_category_id'
  
  # Relationship
  has_many :supplies, :class_name => "Consumable", :foreign_key => "consumable_category_id"
  has_many :enabled_supplies, :class_name => "Consumable", :foreign_key => "consumable_category_id", :conditions => {:enable => true}
  has_many :disabled_supplies, :class_name => "Consumable", :foreign_key => "consumable_category_id", :conditions => {:enable => false}
  has_many :enabled_categories, :class_name => "ConsumableCategory", :foreign_key => "consumable_category_id", :conditions => {:enable => true}
  has_many :disabled_categories, :class_name => "ConsumableCategory", :foreign_key => "consumable_category_id", :conditions => {:enable => false}
  
  # Named Scope
  named_scope :enabled_roots, :conditions => {:enable => true, :consumable_category_id => nil}
  named_scope :roots_children, :conditions => 'consumable_category_id is not null and enable is true'  
  
  # Validates  
  validates_uniqueness_of :name
  validates_presence_of :unit_measure_id, :if => ("consumable_category_id".to_sym)
  validates_persistence_of :name, :consumable_category_id, :unit_measure_id, :unless => :enable
  
  @@form_labels[:consumable_category] = "Appartient à :"
end
