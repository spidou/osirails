class DeliveryNoteType < ActiveRecord::Base
  validates_presence_of :title
  
  validates_uniqueness_of :title
  
  validates_inclusion_of :delivery, :installation, :in => [true, false]
  
  has_search_index :only_attributes => [ :id, :title ],
                   :identifier      => :title
  
  def delivery?
    delivery
  end
  
  def installation?
    installation
  end
end
