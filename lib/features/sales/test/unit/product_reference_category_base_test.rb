module ProductReferenceCategoryBaseTest
  
  class << self
    def included base
      base.class_eval do
        
        #has_permissions :as_business_object
        
        should_have_many :product_reference_sub_categories, :disabled_product_reference_sub_categories, :all_product_reference_sub_categories
        
        should_validate_presence_of :reference, :name
        
        should_validate_uniqueness_of :name, :scoped_to => [ :type, :product_reference_category_id ], :case_sensitive => false
        
        #validates_persistence_of :reference, :unless => :can_update_reference?
        
        should_not_allow_mass_assignment_of :cancelled_at
        
      end
    end
  end
  
end
