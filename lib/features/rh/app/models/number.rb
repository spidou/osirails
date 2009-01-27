class Number < ActiveRecord::Base
  belongs_to :indicative
  belongs_to :number_type
  belongs_to :has_number, :polymorphic => true
  
  validates_format_of 'number',:with => /^[0-9]{9}$/, :message => " le numéro doit contenir 10 chiffres"
  
  def formated
#    formated_number = "0"
#    formated_number << self.number[0..2]
#    formated_number << " "
#    formated_number << self.number[3..4]
#    formated_number << " "
#    formated_number << self.number[5..6]
#    formated_number << " "
#    formated_number << self.number[7..8]
#    return formated_number
    "0#{self.number[0..2]} #{self.number[3..4]} #{self.number[5..6]} #{self.number[7..8]}"
  end
  
  def visible?
    self.visible
  end
end
 
