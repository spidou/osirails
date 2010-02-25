class PressProofItem < ActiveRecord::Base
  belongs_to :press_proof
  belongs_to :graphic_item_version
  
  acts_as_list :scope => :press_proof
  
  attr_accessor :should_destroy
  
  def should_destroy? 
    should_destroy.to_i == 1
  end
end
