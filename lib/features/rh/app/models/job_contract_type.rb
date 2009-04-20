class JobContractType < ActiveRecord::Base
  # Relationships
  has_one :job_contract #TODO relation_inutile? ? "supprimer la relation et vérifier que les job_contracts fonctionnent toujours" : "laisser la relation"

  # Validations
  validates_presence_of :limited, :name
end
