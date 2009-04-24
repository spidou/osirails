class JobContractType < ActiveRecord::Base

  has_search_index  :only_attributes => ["limited","name"]#,
                   # :additional_attributes => {"name" => "string"}

  has_one :job_contract #TODO relation_inutile? ? "supprimer la relation et vérifier que les job_contracts fonctionnent toujours" : "laisser la relation"

  # Validations
  validates_presence_of :limited, :name
end
