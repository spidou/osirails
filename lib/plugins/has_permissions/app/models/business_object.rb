class BusinessObject < ActiveRecord::Base
  setup_has_permissions_model
  
  validates_uniqueness_of :name
  validate :validates_name_is_a_constant
  
  def validates_name_is_a_constant
    begin
      name.constantize
    rescue NameError => e
      errors.add(:name, "ne correspond pas à un modèle valide")
    end
  end
  
  def title
    name.titleize
  end
  
end
