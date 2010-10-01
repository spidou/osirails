class City < ActiveRecord::Base
  belongs_to :country
  belongs_to :region
    
  validates_presence_of :name
  validates_presence_of :zip_code
  validates_presence_of :country_id
  
  validate :validates_region_and_country_coherence
  
  def validates_region_and_country_coherence
    if self.region_id && self.country_id
      errors.add(:region_id, "Le pays de la région sélectionné ne correspond pas au pays sélectionné") if self.region.country_id != self.country_id
    end
  end
end
