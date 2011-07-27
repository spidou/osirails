class ManufacturingStep < ActiveRecord::Base
  has_permissions :as_business_object
  
  acts_as_step
  
  has_many :manufacturing_progresses
  
  belongs_to :production_step
  
  with_options :if => :manufacturing_started_on do |x|
    x.validates_date :manufacturing_started_on, :on_or_before => Date.today
  end
  
  with_options :if => :manufacturing_finished_on do |x|
    x.validates_date :manufacturing_finished_on, :on_or_before => Date.today
    x.validates_date :manufacturing_finished_on, :on_or_after => :manufacturing_started_on
  end
  
  validates_persistence_of :manufacturing_started_on, :if => :manufacturing_started_on_was
  
  validates_persistence_of :manufacturing_finished_on, :manufacturing_progresses, :if => :terminated?
  
  validates_associated :manufacturing_progresses
  
  validate :validates_manufacturing_dates
  
  after_save :save_manufacturing_progresses
  after_save :update_status
  
  active_counter :model => 'Order', :callbacks => { :production_orders  => :after_save,
                                                    :production_total   => :after_save }
  
  has_search_index :only_attributes       => [ :status, :started_at, :finished_at, :manufacturing_started_on, :manufacturing_finished_on ],
                   :additional_attributes => { :global_progression => :integer, :number_of_built_pieces => :integer, :number_of_available_to_deliver_pieces => :integer }
  
  #TODO test this method
  def validates_manufacturing_dates
   errors.add(:manufacturing_started_on, errors.generate_message(:manufacturing_started_on, :blank)) if !manufacturing_started_on and ( global_progression > 0  or manufacturing_finished_on )
   
   errors.add(:manufacturing_finished_on, errors.generate_message(:manufacturing_finished_on, :blank))     if !manufacturing_finished_on and ( global_progression_max? or terminated? )
   errors.add(:manufacturing_finished_on, errors.generate_message(:manufacturing_finished_on, :not_blank)) if manufacturing_finished_on and !global_progression_max?
  end
  
  #TODO test this method
  def signed_quote
    order and order.signed_quote
  end
  
  #TODO test this method
  def end_products
    signed_quote ? signed_quote.end_products : []
  end
  
  #TODO test this method
  def number_of_products
    manufacturing_progresses.size
  end
  
  #TODO test this method
  def number_of_pieces
    manufacturing_progresses.collect{ |mp| mp.end_product.quantity }.sum
  end
  
  #TODO test this method
  def global_progression
    number_of_pieces > 0 ? manufacturing_progresses.collect(&:progression).sum / number_of_products : 0
  end
  
  #TODO test this method
  def global_progression_max?
    global_progression == 100
  end
  
  #TODO test this method
  def number_of_building_pieces
    manufacturing_progresses.collect(&:building_quantity).sum
  end
  
  #TODO test this method
  def number_of_built_pieces
    manufacturing_progresses.collect(&:built_quantity).sum
  end
  
  #TODO test this method
  def number_of_available_to_deliver_pieces
    manufacturing_progresses.collect(&:available_to_deliver_quantity).sum
  end
  
  #TODO test this method
  def ready_to_deliver_end_products_and_quantities
    return [] unless end_products.any?
    
    @ready_to_deliver_end_products_and_quantities = end_products.collect do |end_product|
      if mp = manufacturing_progresses.detect{ |mp| mp.end_product_id == end_product.id }
        { :end_product_id => mp.end_product_id, :quantity => mp.available_to_deliver_quantity }
      else
        nil
      end
    end.compact.select{ |h| h[:quantity] > 0 }
  end
  
  #TODO test this method
  def all_products_available_to_deliver?
    number_of_available_to_deliver_pieces == end_products.collect(&:quantity).sum
  end
  
  #TODO test this method
  def manufacturing_progresses_attributes=(attributes)
    attributes.each do |attributes|
      if attributes[:id].blank?
        manufacturing_progresses.build(attributes)
      else
        manufacturing_progress = manufacturing_progresses.detect {|t| t.id == attributes[:id].to_i}
        manufacturing_progress.attributes = attributes
      end
    end
  end
  
  #TODO test this method
  def save_manufacturing_progresses
    manufacturing_progresses.each do |p|
      p.save(false)
    end
  end
  
  #TODO test this method
  def build_manufacturing_progresses_from_end_products
    end_products.each do |end_product|
      unless manufacturing_progresses.detect{ |p| p.end_product_id == end_product.id }
        manufacturing_progresses.build(:end_product_id => end_product.id)
      end
    end
  end
  
  private
    #TODO test this method
    def update_status
      self.terminated! if signed_quote and all_products_available_to_deliver?
    end
end
