class Customer < Third
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  
  validates_uniqueness_of :name, :siret_number
  
  # Name Scope
  named_scope :activates, :conditions => {:activated => true}
  
  ## Plugins
  acts_as_file
  
  def activated_establishments
    establishment_array = []
    self.establishments.each {|establishment| establishment_array << establishment if establishment.activated}
    return establishment_array
  end
  
  # customer.contacts_all            => array
  # 
  # return the direct contacts of the customer,
  # with the contacts of all its establishments.
  #
  def contacts_all
    contacts = []
    #OPTIMIZE can this loop be optimize with an unique sql request ?
    self.establishments.each do |establishment|
      establishment.contacts.each do |contact|
        contacts << contact
      end
    end
    
    self.contacts + contacts
  end
  
end