class ProductReferenceCategory < ActiveRecord::Base
  has_permissions :as_business_object
  has_reference   :symbols => [:product_reference_category], :prefix => :sales
  
  acts_as_tree :order => :name, :foreign_key => :product_reference_category_id
  
  belongs_to :product_reference_category
  
  has_many :product_references, :conditions => [ "cancelled_at IS NULL" ]
  has_many :product_reference_categories, :conditions => [ "cancelled_at IS NULL" ]
  
  has_many :disabled_product_references, :class_name => "ProductReference", :conditions => [ "cancelled_at IS NOT NULL" ]
  has_many :disabled_product_reference_categories, :class_name => "ProductReferenceCategory", :conditions => [ "cancelled_at IS NOT NULL" ]
  
  has_many :all_product_references, :class_name => "ProductReference"
  has_many :all_product_reference_categories, :class_name => "ProductReferenceCategory"
  
  named_scope :actives, :conditions => ["cancelled_at IS NULL"]
  
  validates_presence_of :reference, :name
  
  has_search_index  :only_attributes      => [ :name ],
                    :only_relationships   => [ :parent ]
  
  before_validation_on_create :set_reference
  
  before_destroy :can_be_destroyed?
  
  attr_protected :cancelled_at
  
  cattr_reader :form_labels
  @@form_labels = Hash.new
  @@form_labels[:name]                        = "Nom :"
  @@form_labels[:product_reference_category]  = "Catégorie parente :"
  
  def set_reference
    if product_reference_category_id or product_reference_category
      update_reference
    end
  end
  
  def enabled?
    !cancelled_at
  end
  
  def was_enabled?
    !cancelled_at_was
  end
  
  def can_be_disabled?
    was_enabled?
  end
  
  def can_be_destroyed?
    product_references.empty? and product_reference_categories.empty?
  end
  
  def disable
    if can_be_disabled?
      self.cancelled_at = Time.now
      self.save
    end
  end
  
  def product_references_count
    if parent
      self[:product_references_count]
    else
      product_reference_categories.collect(&:product_references_count).sum
    end
  end
  
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
  
  def disabled_children
    disabled_product_references + disabled_product_reference_categories
  end
  
  def has_disabled_children?
    disabled_children.any?
  end
  
end
