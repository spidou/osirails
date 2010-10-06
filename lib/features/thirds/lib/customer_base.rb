module CustomerBase
  class << self
    def included base #:nodoc:
    # TODO make establishment polymorphic to allow customers, forwarders and suppliers to use it and then uncomment those lines to not repeat the code in both forwarder and customer and comment corresponding lines in customer.rb
      base.class_eval do
        belongs_to :creator, :class_name => 'User'
      
#        has_one  :head_office
        
#        has_many :establishments, :as => :has_establishment, :conditions => ['establishments.type IS NULL and ( hidden = ? or hidden IS NULL )', false]
        
        named_scope :activates, :conditions => { :activated => true }
        
#        validates_presence_of :head_office
        
#        validates_associated :establishments, :head_office
        
#        validate :validates_uniqueness_of_siret_number
        
#        after_save :save_establishments, :save_head_office
      end
    end
  end
  
#  def head_office_and_establishments
#    @head_office_and_establishments ||= ( [ head_office ] + establishments ).compact
#  end
#  
#  def contacts
#    @contacts ||= head_office_and_establishments.collect(&:contacts).flatten
#  end
#  
#  def establishment_attributes=(establishment_attributes)
#    establishment_attributes.each do |attributes|
#      if attributes[:id].blank?
#        establishments.build(attributes)
#      else
#        establishment = establishments.detect { |t| t.id == attributes[:id].to_i }
#        establishment.attributes = attributes
#      end
#    end
#  end
#  
#  def head_office_attributes=(head_office_attributes)
#    attributes = head_office_attributes.first
#    if head_office.nil?
#      build_head_office(attributes)
#    else
#      head_office.attributes = attributes 
#    end
#  end
#  
#  def save_head_office
#    head_office.save(false)
#  end
#  
#  def save_establishments
#    establishments.each do |e|
#      if e.should_destroy?
#        e.destroy
#      elsif e.should_hide?
#        e.hide
#      elsif e.should_update?
#        e.save(false)
#      end
#    end
#  end
#  
#  def activated_establishments
#    establishments.select(&:activated)
#  end
#  
#  def build_establishment(attributes = {})
#    self.establishments.build(attributes)
#  end
#    
#  def validates_uniqueness_of_siret_number
#    establishments    = head_office_and_establishments
#    all_siret_numbers = {}
#    establishments.each{ |n| all_siret_numbers.merge!(n => n.siret_number) }
#    
#    message = "est déjà pris par un autre établissement (ou le siège social) de ce client"
#    establishments.each do |establishment|
#      other_siret_numbers = all_siret_numbers.reject{ |estab, siret_number| establishment == estab }
#      establishment.errors.add(:siret_number, message) if other_siret_numbers.values.include?(establishment.siret_number)
#    end
#  end
end
