class Number < ActiveRecord::Base
  belongs_to :indicative
  belongs_to :number_type
  belongs_to :has_number, :polymorphic => true
  
  validates_format_of 'number',:with => /^[0-9]{9}$/, :message => " le numéro doit contenir 10 chiffres"
  
  attr_accessor :should_destroy 

  VISIBLE_STATES = {"Privé"=> false,"Public" => true} 
  
  def formatted
    # OPTIMIZE see the helper method in NumberHelper called 'to_phone' to format the phone number
    "0#{self.number[0..2]} #{self.number[3..4]} #{self.number[5..6]} #{self.number[7..8]}"
  end
  
  def visible?
    self.visible
  end
  
  def should_destroy?
    should_destroy.to_i == 1  
  end

end
 
