class DeliveryNoteType < ActiveRecord::Base
  validates_presence_of :title
  
  validates_uniqueness_of :title
  
  validates_inclusion_of :delivery, :installation, :in => [true, false]
  
  def delivery?
    delivery
  end
  
  def installation?
    installation
  end
end
