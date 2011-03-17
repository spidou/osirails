require 'lib/seed_helper'

# personalized_queries
Query.create! do |q|
  q.creator       = User.first
  q.name          = I18n.t('seeds.query.all_employees')
  q.criteria      = {}
  q.page_name     = "employee_index"
  q.search_type   = "or"
  q.columns       = ["civility.name", "last_name", "first_name", "service.name", "job_contract.job_contract_type.name"]
  q.order         = ["last_name:asc", "first_name:asc"]
  q.public_access = true
  q.per_page      = 50
end

# default civilities
Civility.create! :name => "M."
Civility.create! :name => "Mme"
Civility.create! :name => "Melle"

# default family situations
FamilySituation.create! :name => "Célibataire"
FamilySituation.create! :name => "Marié(e)"
FamilySituation.create! :name => "Veuf/Veuve"
FamilySituation.create! :name => "Divorcé(e)"
FamilySituation.create! :name => "Pacsé(e)"

# default employee states
EmployeeState.create! :name => "Titulaire",       :active => true
EmployeeState.create! :name => "Stagiaire",       :active => true
EmployeeState.create! :name => "Licencié(e)",     :active => false
EmployeeState.create! :name => "Démissionnaire",  :active => false

# default job contract types
JobContractType.create! :name => "CDI", :limited => 0
JobContractType.create! :name => "CDD", :limited => 1

# default leave types
LeaveType.create! :name => "Congés payés"
LeaveType.create! :name => "Congé maladie"
LeaveType.create! :name => "Congé maternité"
LeaveType.create! :name => "Congé paternité"
LeaveType.create! :name => "Congés spéciaux"
LeaveType.create! :name => "Récupération"

## default document types (document types are created automatically when the class of the owner is parsed)
#### get mime types
pdf = MimeType.find_by_name("application/pdf")
jpg = MimeType.find_by_name("image/jpeg")
png = MimeType.find_by_name("image/png")
####
# for employees
d = DocumentType.find_or_create_by_name("curriculum_vitae")
d.update_attribute(:title, "Curriculum Vitae (CV)")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("driving_licence")
d.update_attribute(:title, "Permis de conduire")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("identity_card")
d.update_attribute(:title, "Pièce d'identité")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("other")
d.update_attribute(:title, "Autre")
d.mime_types << [ pdf, jpg, png ]

# for job contract
d = DocumentType.find_or_create_by_name("job_contract")
d.update_attribute(:title, "Contrat de travail")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("job_contract_endorsement")
d.update_attribute(:title, "Avenant au contrat de travail")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("resignation_letter")
d.update_attribute(:title, "Lettre de licenciement")
d.mime_types << [ pdf, jpg, png ]
d = DocumentType.find_or_create_by_name("demission_letter")
d.update_attribute(:title, "Lettre de démission")
d.mime_types << [ pdf, jpg, png ]

set_default_permissions
