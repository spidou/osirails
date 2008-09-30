class JobContractType < ActiveRecord::Base
  has_one :job_contract #TODO relation_inutile? ? "supprimer la relation et vérifier que les job_contracts fonctionnent toujours" : "laisser la relation"
end
