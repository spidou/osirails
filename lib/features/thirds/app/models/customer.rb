class Customer < Third
  has_permissions     :as_business_object
  has_documents       :graphic_charter, :logo
  has_address         :bill_to_address
  
  belongs_to :payment_method
  belongs_to :payment_time_limit
  
  has_many :establishments
  
  validates_presence_of   :bill_to_address
  validates_uniqueness_of :name, :siret_number # don't put that in third.rb because validation should be only for customer (and not all thirds)
  validates_length_of     :establishment_ids, :minimum => 1, :too_short => "Vous devez créer au moins 1 établissement"
  validates_associated    :establishments
  
  after_save :save_establishments
  
  # for pagination : number of instances by index page
  CUSTOMERS_PER_PAGE = 15
  
  named_scope :activates, :conditions => {:activated => true}
  
  has_search_index :only_attributes    => [:name, :siret_number],
                   :only_relationships => [:activity_sector, :legal_form, :establishments],
                   :main_model         => true
  
  def contacts
    establishments.collect(&:contacts).flatten
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
  
  def activated_establishments
    establishments.select(&:activated)
  end
  
  def build_establishment(attributes = {})
    self.establishments.build(attributes)
  end

end
