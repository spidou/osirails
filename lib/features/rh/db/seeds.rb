require 'lib/seed_helper'

# default civilities
Civility.create! :name => "Mr"
Civility.create! :name => "Mme"
Civility.create! :name => "Mademoiselle"

# default family situations
FamilySituation.create! :name => "Célibataire"
FamilySituation.create! :name => "Marié(e)"
FamilySituation.create! :name => "Veuf/Veuve"
FamilySituation.create! :name => "Divorcé(e)"
FamilySituation.create! :name => "Pacsé(e)"

# default employee states
EmployeeState.create! :name => "Titulaire",       :active => 1
EmployeeState.create! :name => "Stagiaire",       :active => 1
EmployeeState.create! :name => "Licencié(e)",     :active => 0
EmployeeState.create! :name => "Démissionnaire",  :active => 0

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

# default jobs
Job.create! :name => "Directeur Général",                     :service_id => Service.find_by_name("Direction Générale").id, :responsible => true
Job.create! :name => "Directeur Commercial",                  :service_id => Service.find_by_name("Commercial").id, :responsible => true
Job.create! :name => "Commercial",                            :service_id => Service.find_by_name("Commercial").id
Job.create! :name => "Chargé d'affaires",                     :service_id => Service.find_by_name("Commercial").id
Job.create! :name => "Directeur Administratif et Financier",  :service_id => Service.find_by_name("Administratif et Financier").id, :responsible => true
Job.create! :name => "Secrétaire",                            :service_id => Service.find_by_name("Administratif et Financier").id
Job.create! :name => "Assistante de Direction",               :service_id => Service.find_by_name("Administratif et Financier").id
Job.create! :name => "Comptable",                             :service_id => Service.find_by_name("Administratif et Financier").id
Job.create! :name => "Assistante des Ressources Humaines",    :service_id => Service.find_by_name("Administratif et Financier").id
Job.create! :name => "Responsable des Achats/Ventes",         :service_id => Service.find_by_name("Achats/Ventes").id, :responsible => true
Job.create! :name => "Assistante des Achats/Ventes",          :service_id => Service.find_by_name("Achats/Ventes").id
Job.create! :name => "Ingénieur Informaticien",               :service_id => Service.find_by_name("Informatique").id, :responsible => true
Job.create! :name => "Responsable de Production",             :service_id => Service.find_by_name("Production").id, :responsible => true
Job.create! :name => "Responsable Décor",                     :service_id => Service.find_by_name("Décor").id, :responsible => true
Job.create! :name => "Graphiste Sénior",                      :service_id => Service.find_by_name("Décor").id
Job.create! :name => "Graphiste",                             :service_id => Service.find_by_name("Décor").id
Job.create! :name => "Poseur de film",                        :service_id => Service.find_by_name("Décor").id
Job.create! :name => "Chef d'équipe Plasturgie",              :service_id => Service.find_by_name("Plasturgie").id
Job.create! :name => "Monteur Câbleur",                       :service_id => Service.find_by_name("Électricité").id
Job.create! :name => "Plasticien Monteur",                    :service_id => Service.find_by_name("Électricité").id
Job.create! :name => "Chef d'équipe Métallier",               :service_id => Service.find_by_name("Métallerie").id
Job.create! :name => "Métallier",                             :service_id => Service.find_by_name("Métallerie").id
Job.create! :name => "Chaudronnier",                          :service_id => Service.find_by_name("Métallerie").id
Job.create! :name => "Dessinateur Fraiseur",                  :service_id => Service.find_by_name("Métallerie").id
Job.create! :name => "Peintre",                               :service_id => Service.find_by_name("Peinture").id
Job.create! :name => "Chef d'équipe Pose",                    :service_id => Service.find_by_name("Pose").id
Job.create! :name => "Poseur d'enseignes",                    :service_id => Service.find_by_name("Pose").id
Job.create! :name => "Poseur",                                :service_id => Service.find_by_name("Pose").id

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
