class Customer < Third
  belongs_to :payment_method
  belongs_to :payment_time_limit
  has_many :establishments
  
  ## Validations
  validates_uniqueness_of :name, :siret_number
  validates_associated :establishments, :contacts
  
  # Name Scope
  named_scope :activates, :conditions => {:activated => true}
  
  ## Plugins
  acts_as_file
  #has_document
  
  ## Callbacks
  after_update :save_establishments
  
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
  
  def establishment_attributes=(establishment_attributes)
    establishment_attributes.each do |attributes|
      if attributes[:id].blank?
        establishments.build(attributes)
      else
        establishment = establishments.detect { |t| t.id == attributes[:id].to_i }
        establishment.attributes = attributes
      end
    end
  end
  
  def save_establishments
    establishments.each do |e|
      if e.should_destroy?
        e.destroy
      elsif e.should_update?
        e.save(false)
      end
    end
  end
  
  ######################
  # OPTIMIZE place these methods in the acts_as_file module
  def document_attributes=(document_attributes)
#    raise document_attributes.inspect
    document_attributes.each do |attributes|
#      attributes[:name] = attributes[:file].original_filename if attributes[:name].blank?
      if attributes[:id].blank?
        documents.build(attributes)
      else
        document = documents.detect { |t| t.id == attributes[:id].to_i }
        document.attributes = attributes
      end
    end
  end
  
  after_update :save_documents
  
  def save_documents
    documents.each do |d|
      if d.should_destroy?
        d.destroy
      elsif d.should_update?
        d.save(false)
      end
    end
  end
  #######################""
  
end
