class ProductReferenceCategory < ActiveRecord::Base
  has_permissions :as_business_object
 
  # Plugin
  acts_as_tree :order => :name, :foreign_key => "product_reference_category_id"
  
  # Relationship
  has_many :product_references
  has_many :product_reference_categories
  belongs_to :product_reference_category
  
  # Validation Macros
  validates_presence_of :name, :message => "ne peut être vide"
  
  has_search_index  :only_attributes      => [:name],
                    :only_relationships   => [:parent]
                    
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]                        = "Nom :"
  @@form_labels[:product_reference_category]  = "Catégorie parente :"
  
  # This method permit to update counter of parents categories
  def counter_update(index,value)
    category = ProductReferenceCategory.find(self.id)
    case index
    when "before_update"
      ProductReferenceCategory.update_counters(category.id, :product_references_count => -value)
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => -value)
      end
    when "after_update"
      ProductReferenceCategory.update_counters(category.id, :product_references_count => value)
      category.ancestors.each do |parent_category|
        ProductReferenceCategory.update_counters(parent_category.id, :product_references_count => value)
      end
    end
  end
  
  # This method permit to check if a category can have a new parent category
  def can_has_this_parent?(new_parent_category_id)
    return true if new_parent_category_id == "" or new_parent_category_id.nil?
    new_parent = ProductReferenceCategory.find(new_parent_category_id)
    return false if new_parent.id == self.id or new_parent.ancestors.include?(self)
    true
  end
  
  # This method permit to change category
  def change_category(new_parent_category_id)
    if self.can_has_this_parent?(new_parent_category_id) and new_parent_category_id.to_s != self.product_reference_category_id.to_s
      self.product_reference_category_id = new_parent_category_id
      self.save
    end
  end
  
  # Check if category should be deleted or not
  def can_be_destroyed?
    self.product_references.empty? and self.product_reference_categories.empty?
  end
  
  # Check if a category have got children disable
  def has_children_disable?
    references = ProductReference.find(:all, :conditions => {:product_reference_category_id => self.id, :enable => false})
    categories = ProductReferenceCategory.find(:all, :conditions => {:product_reference_category_id => self.id, :enable => false})
    references.size > 0 or categories.size > 0
  end
  
end
