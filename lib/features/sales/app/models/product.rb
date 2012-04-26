## DATABASE STRUCTURE
# A string   "type"
# A integer  "product_reference_sub_category_id"
# A integer  "end_products_count",                :default => 0
# A integer  "product_reference_id"
# A integer  "order_id"
# A float    "prizegiving"
# A float    "unit_price"
# A integer  "quantity"
# A integer  "position"
# A string   "reference"
# A string   "name"
# A integer  "width"
# A integer  "length"
# A integer  "height"
# A text     "description"
# A float    "vat"
# A datetime "cancelled_at"
# A datetime "created_at"
# A datetime "updated_at"

class Product < ActiveRecord::Base # @abstract
  include ProductDimensions
  
  named_scope :actives, :conditions => [ "cancelled_at IS NULL" ]
  
  validates_presence_of :name, :unless => :should_destroy?
  
  after_save :clean_caches
  
  attr_accessor :should_destroy
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  #TODO test this method
  def enabled?
    !cancelled_at
  end
  
  #TODO test this method
  def was_enabled?
    !cancelled_at_was
  end
  
  #TODO test this method
  def disable
    self.cancelled_at = Time.now
    self.save
  end
  
  def ancestors
    raise "Product doesn't implement 'ancestors'. A subclass may override this method"
  end
  
  #TODO test this method
  def designation
    (ancestors + [self]).collect(&:name).join(" ")
  end
  
  #TODO test this method
  def designation_with_dimensions
    designation + ( dimensions.blank? ? "" : " (#{dimensions})" )
  end
  
  def duplicate
    self.class.new(self.attributes)
  end
  
#  before_destroy :cancel_if_cannot_be_destroyed
#  
#  def cancel
#    self.cancelled_at = Time.now
#    self.save
#  end
#  
#  # product cannot be destroyed if it already associated with at least one quote_item, mockup or press_proof
#  def can_be_destroyed?
#    quote_items.empty? and mockups.empty? and press_proofs.empty?
#  end
#  
#  private
#    
#    def cancel_if_cannot_be_destroyed
#      unless can_be_destroyed?
#        self.cancel
#        return false
#      end
#    end
#  

  private
    def clean_caches
    end
end
