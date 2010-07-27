# default employees
john = Employee.new :first_name => "John", :last_name => "Doe", :birth_date => Date.today - 20.years, :email => "john@doe.com", :social_security_number => "1234567891234 45", :service_id => Service.first.id, :civility_id => Civility.first.id, :family_situation_id => FamilySituation.first.id, :qualification => "Inconnu"
john.numbers.build(:number => "692123456", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
john.numbers.build(:number => "262987654", :indicative_id => Indicative.first.id, :number_type_id => NumberType.last.id)
john.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
john.build_iban(:bank_name => "Bred", :account_name => "John DOE" , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
john.save!
john.jobs << Job.first
john.user.roles << Role.first
john.user.enabled = true
john.user.save!
john.job_contract.update_attributes(:start_date => Date.today, :end_date => Date.today + 1.years, :job_contract_type_id => JobContractType.first.id, :employee_state_id => EmployeeState.first.id, :salary => "2000")

###########
first_names = %W( pierre paul jacques jean fabrice patricia marie julie isabelle )
last_names  = %W( dupont hoarau turpin payet grondin boyer)
numbers     = %W( 18 20 22 23 30 35 40 45 )
addresses   = %W( rosiers palmiers lauriers Champs-Elizées cocotiers )
countries   = %W( Reunion France Espagne Italie EtatsUnis )
cities      = %W( SaintDenis Paris Madrid Rome NewYork )
banks       = %W( Bred BR CreditAgricole BFC )
###########
20.times do |i|
  employee = john.clone
  employee.first_name = first_names.rand
  employee.last_name = last_names.rand
  employee.email = "#{employee.first_name}@#{employee.last_name}.com"
  employee.birth_date = Date.today - numbers.rand.to_i.years - numbers.rand.to_i.days
  employee.build_address(:street_name => "#{numbers.rand} rue des #{addresses.rand}", :country_name => "#{countries.rand}", :city_name => "#{cities.rand}", :zip_code => rand(99999).to_s)
  employee.build_iban(:bank_name => banks.rand, :account_name => employee.fullname , :bank_code => "12345", :branch_code => "12345", :account_number => "12345678901", :key => "12")
  employee.service = Service.all.rand
  employee.save!
  [1,1,1,1,1,1,1,2,2,3].rand.times do |j|
    job = Job.all.rand
    ( employee.jobs << job ) unless employee.jobs.include?(job)
  end
end
