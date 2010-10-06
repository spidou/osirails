module SupplierBase
  class << self
    def included base #:nodoc:
      base.class_eval do
        has_one :iban, :as => :has_iban
        
        validates_uniqueness_of :siret_number, :scope => :type, :allow_blank => true
        
        after_save :save_iban
      end
    end
  end
  
  def iban_attributes=(iban_attributes)
    if iban_attributes[:id].blank?
      self.iban = build_iban(iban_attributes)
    else
      self.iban.attributes = iban_attributes
    end
  end
  
  def save_iban
    iban.save if iban
  end
end
