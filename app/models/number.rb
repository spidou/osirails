class Number < ActiveRecord::Base
  
  belongs_to :indicative
  belongs_to :number_type
  belongs_to :has_number, :polymorphic => true
  
  validates_presence_of :has_number_type, :indicative_id, :number_type_id
  validates_presence_of :indicative,  :if => :indicative_id
  validates_presence_of :number_type, :if => :number_type_id
  
  validates_length_of :number, :is => 9
  
  attr_accessor :should_destroy
  
  named_scope :visibles, :conditions => ['visible=?',true]
  
  VISIBLE_STATES = { "Privé" => false, "Public" => true }
  
  has_search_index  :only_attributes    => [:number],
                    :only_relationships => [:number_type, :indicative]
  
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
