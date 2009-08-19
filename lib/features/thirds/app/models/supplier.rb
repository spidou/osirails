class Supplier < Third
  has_permissions :as_business_object
  
  has_one :iban, :as => :has_iban
  
  named_scope :activates, :conditions => {:activated => true}
  
  validates_uniqueness_of :name, :siret_number # don't put that in third.rb because validation should be only for customer (and not all thirds)

  after_update :save_iban
  
  has_search_index :only_attributes    => [:name, :siret_number],
                   :only_relationships => [:activity_sector, :legal_form, :iban, :contacts],
                   :main_model         => true

  def iban_attributes=(iban_attributes)
    if iban_attributes[:id].blank?
      self.iban = build_iban(iban_attributes)
    else
      self.iban.attributes = iban_attributes
    end
  end

  def save_iban
    iban.save
  end
end
