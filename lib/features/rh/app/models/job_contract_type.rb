class JobContractType < ActiveRecord::Base
  # Relationships
  has_one :job_contract #TODO relation_inutile? ? "supprimer la relation et vérifier que les job_contracts fonctionnent toujours" : "laisser la relation"

  # Validations
  #FIXME validate presence of limited doesn't work properly because if it 's false the validates presence of return an error for limited  
  validates_presence_of :limited, :name
end
