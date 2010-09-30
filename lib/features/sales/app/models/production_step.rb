class ProductionStep < ActiveRecord::Base
  has_permissions :as_business_object
  acts_as_step
  
  has_many :production_progresses
  belongs_to :pre_invoicing_step
  
  with_options :if => :begining_production_on do |x|
    x.validates_date :begining_production_on, :on_or_before => Date.today
    x.validates_date :begining_production_on, :on_or_before => :ending_production_on
  end
  
  with_options :if => :ending_production_on do |x|
    x.validates_date :ending_production_on, :on_or_before => Date.today
    x.validates_date :ending_production_on, :on_or_after => :begining_production_on
  end

  validates_associated :production_progresses
  
  validate :validates_ending_production_date
  
  after_save :save_production_progresses
  
  cattr_accessor :form_labels
  @@form_labels = Hash.new
  @@form_labels[:begining_production_on]             = "Entr&eacute;e en production le :"
  @@form_labels[:ending_production_on]               = "Sortie en production le :"
  
  def validates_ending_production_date
   self.errors.add(:begining_production_on, "requis si ending_production_on est present") if self.ending_production_on && !self.begining_production_on
   self.errors.add(:ending_production_on, "Progression doit etre a 100 % avant de definir la date de fin de production") if self.ending_production_on && self.begining_production_on && self.global_progression.to_i != 100
  end
  
  def save_production_progresses
    for production_progress in self.production_progresses
      production_progress.save(false)
    end
  end
  
  def number_of_products
    self.production_progresses.size
  end
  
  def number_of_pieces
    self.production_progresses.collect{|n| n.product.quantity}.sum
  end
  
  def global_progression
    (number_of_products && number_of_products > 0) ? production_progresses.collect(&:progression).sum / number_of_products : 0.0
  end
  
  def numbers_of_available_to_deliver_products
    production_progresses.collect(&:available_to_deliver_quantity).sum
  end
  
  def numbers_of_built_products
    production_progresses.collect(&:built_quantity).sum
  end
  
  def production_progresses_attributes=(attributes)
    attributes.each do |attributes|
      if attributes[:id].blank?
        self.production_progresses.build(attributes)
      else
        production_progress = self.production_progresses.detect {|t| t.id == attributes[:id].to_i} 
        production_progress.attributes = attributes
      end
    end
  end
  
  def end_products
    order.end_products if order
  end
  
  def build_production_progresses_with_end_products
    for end_product in end_products
      unless production_progresses.detect{|t| t.product_id == end_product.id}
        production_progresses.build({:product_id => end_product.id})
      end
    end
  end
  
end
