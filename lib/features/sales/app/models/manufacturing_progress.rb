class ManufacturingProgress < ActiveRecord::Base
  has_permissions :as_business_object
  
  belongs_to :end_product
  belongs_to :manufacturing_step
  
  validates_presence_of :manufacturing_step_id, :end_product_id
  validates_presence_of :manufacturing_step, :if => :manufacturing_step_id
  validates_presence_of :end_product,        :if => :end_product_id
  
  with_options :greater_than_or_equal_to => 0 do |p|
    p.validates_numericality_of :building_quantity, :built_quantity
    p.validates_numericality_of :available_to_deliver_quantity#, :less_than_or_equal_to => :built_quantity #TODO make validates_numericality_of able to take Proc or Symbol
                                                                                                           # the expected behaviour is defined in validates_available_to_deliver_quantity
    p.validates_numericality_of :progression, :less_than_or_equal_to => 100
  end
  
  validate :validates_sum_of_building_quantity_and_build_quantity,
           :validates_progression,
           :validates_available_to_deliver_quantity
  
  
  def progression
    self[:progression] ||= 0
  end
  
  def built_quantity
    self[:built_quantity] ||= 0
  end
  
  def building_quantity
    self[:building_quantity] ||= 0
  end
  
  def available_to_deliver_quantity
    self[:available_to_deliver_quantity] ||= 0
  end
  
  def validates_sum_of_building_quantity_and_build_quantity
    return unless end_product
    
    sum = built_quantity + building_quantity
    if sum < 0 or sum > end_product.quantity
      errors.add(:built_quantity, errors.generate_message(:built_quantity, :invalid_sum, :quantity => end_product.quantity))
      errors.add(:building_quantity, errors.generate_message(:building_quantity, :invalid_sum, :quantity => end_product.quantity))
    end
  end
  
  def validates_available_to_deliver_quantity
    if available_to_deliver_quantity > built_quantity
      errors.add(:available_to_deliver_quantity, errors.generate_message(:available_to_deliver_quantity, :less_than_or_equal_to, :count => built_quantity))
    end
  end
  
  def validates_progression
    return unless end_product
    
    if progression_max? and built_quantity < end_product.quantity
      errors.add(:progression, errors.generate_message(:progression, :max))
    elsif !progression_max? and built_quantity == end_product.quantity
      errors.add(:progression, errors.generate_message(:progression, :not_max))
    end
  end
  
  def building_remaining_quantity
    q = end_product.quantity - built_quantity
    q > 0 ? q : 0
  end
  
  def built_remaining_quantity
    q = end_product.quantity - building_quantity
    q > 0 ? q : 0
  end
  
  def range_for_building_quantity
    (0..building_remaining_quantity)
  end
  
  def range_for_built_quantity
    (0..built_remaining_quantity)
  end
  
  def range_for_available_to_deliver_quantity
    (0..built_quantity)
  end
  
  def progression_max?
    progression == 100
  end
end
