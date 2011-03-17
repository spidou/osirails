require 'lib/seed_helper'

# default jobs
Job.create! :name => "Directeur Général",                     :service_id => Service.find_by_name("Direction Générale").id, :responsible => true
Job.create! :name => "Directeur Administratif et Financier",  :service_id => Service.find_by_name("Administratif et Financier").id, :responsible => true
Job.create! :name => "Secrétaire",                            :service_id => Service.find_by_name("Administratif et Financier").id
Job.create! :name => "Directeur Commercial",                  :service_id => Service.find_by_name("Commercial").id, :responsible => true
Job.create! :name => "Commercial",                            :service_id => Service.find_by_name("Commercial").id
Job.create! :name => "Chargé d'affaires",                     :service_id => Service.find_by_name("Commercial").id

# default employees
john = Employee.new :first_name => "John", :last_name => "Doe", :birth_date => Date.today - 20.years, :email => "john@doe.com", :social_security_number => "1234567891234 45", :service_id => Service.first.id, :civility_id => Civility.first.id, :family_situation_id => FamilySituation.first.id, :qualification => "Inconnu"
john.numbers.build(:number => "692123456", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
john.numbers.build(:number => "262987654", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
john.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
john.build_iban(:bank_name => "Bred", :account_name => "John DOE" , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
john.jobs << Job.find_by_name("Directeur Commercial")
john.save!
john.job_contract.update_attributes(:start_date => Date.today, :end_date => Date.today + 1.years, :job_contract_type_id => JobContractType.first.id, :employee_state_id => EmployeeState.first.id, :salary => "2000")
john.save!
john.user.roles << Role.first
john.user.enabled = true
john.user.save!

employee = john.clone
employee.first_name = "Jane"
employee.last_name = "Doe"
employee.email = "#{employee.first_name}@#{employee.last_name}.com"
employee.birth_date = Date.today - 19.years - 2.months
employee.civility = Civility.find_by_name("Mme")
employee.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
employee.build_iban(:bank_name => "Bred", :account_name => "Jane DOE" , :bank_code => "12365", :branch_code => "12845", :account_number => "22345678901", :key => "11")
employee.service = Service.first
employee.jobs << Job.find_by_name("Commercial")
employee.save!

set_default_permissions
