class JobContractType < ActiveRecord::Base
  has_one :job_contract #TODO relation_inutile? ? "supprimer la relation et vérifier que les job_contracts fonctionnent toujours" : "laisser la relation"

  # Validations
  validates_presence_of :name
  validates_inclusion_of :limited , :in => [true, false]
  
  has_search_index :only_attributes => [:limited, :name]
end
