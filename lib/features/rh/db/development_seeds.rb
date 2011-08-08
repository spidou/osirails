require 'lib/seed_helper'

# default jobs
Job.create! :name => "Directeur Général",                     :service_id => Service.find_by_name("Direction Générale").id, :responsible => true
Job.create! :name => "Directeur Administratif et Financier",  :service_id => Service.find_by_name("Administratif et Financier").id, :responsible => true
Job.create! :name => "Secrétaire",                            :service_id => Service.find_by_name("Administratif et Financier").id
Job.create! :name => "Directeur Commercial",                  :service_id => Service.find_by_name("Commercial").id, :responsible => true
Job.create! :name => "Commercial",                            :service_id => Service.find_by_name("Commercial").id
Job.create! :name => "Chargé d'affaires",                     :service_id => Service.find_by_name("Commercial").id

##### default employees #####
john = Employee.new :first_name => "John", :last_name => "Doe", :service_id => Service.first.id, :civility_id => Civility.first.id
# public numbers
["692243456","692543478","629456232"].each do |number|
  john.numbers.build(:number => number, :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
end
# sensible_datas
john.build_employee_sensitive_data(
  :family_situation_id    => FamilySituation.first.id,
  :social_security_number => "1234567891234 45",
  :birth_date             => Date.today - 20.years,
  :email                  => "john@doe.com"
)
# private_numbers
["692123456", "262987654"].each do |number|
  john.employee_sensitive_data.numbers.build(:number => number, :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
end
#address
john.employee_sensitive_data.build_address(
  :street_name  => "1 rue des rosiers",
  :country_name => "Réunion",
  :city_name    => "Saint-Denis",
  :zip_code     => "97400"
)
# iban
john.employee_sensitive_data.build_iban(
  :bank_name      => "Bred",
  :account_name   => "John DOE",
  :bank_code      => "12345",
  :branch_code    => "12345",
  :account_number => "12345678901",
  :key            => "12"
)
# jobs
john.jobs << Job.find_by_name("Directeur Commercial")
# Save employee
john.save!
# Job_contract
john.job_contracts.create do |j|
  j.start_date           = Date.today
  j.job_contract_type_id = JobContractType.first(:conditions => ["limited=false"]).id
  j.salary               = "2000"
end
#roles
john.user.roles << Role.first
john.user.enabled = true
john.user.save!


#### another employee ####
employee = john.clone
employee.first_name = "Jane"
employee.last_name = "Doe"
employee.numbers.build(:number => "692243996", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
employee.numbers.build(:number => "692546354", :indicative_id => Indicative.first.id, :number_type_id => NumberType.first.id)
employee.build_employee_sensitive_data( :family_situation_id => FamilySituation.first.id, :social_security_number => "1234567891234 45")
employee.employee_sensitive_data.email = "#{employee.first_name}@#{employee.last_name}.com"
employee.employee_sensitive_data.birth_date = Date.today - 19.years - 2.months
employee.civility = Civility.find_by_name("Mme")
employee.employee_sensitive_data.build_address(:street_name => "1 rue des rosiers", :country_name => "Réunion", :city_name => "Saint-Denis", :zip_code => "97400")
employee.employee_sensitive_data.build_iban(:bank_name => "Bred", :account_name => "Jane DOE" , :bank_code => "12365", :branch_code => "12845", :account_number => "22345678901", :key => "11")
employee.service = Service.first
employee.jobs << Job.find_by_name("Commercial")
employee.user = nil # remove john's user to generate a new one for jane doe
employee.save!

employee.job_contracts.create do |j|
  j.start_date           = Date.today
  j.end_date             = Date.today + 1.years
  j.job_contract_type_id = JobContractType.first(:conditions => ["limited=true"]).id
  j.salary               = "1500"
end

# leaves (useful for checkings)
Leave.create!(:employee => Employee.find_by_first_name("Jane"), :leave_type => LeaveType.first, :start_date => Date.today - 20, :end_date => Date.today - 18, :start_half => false, :end_half => false, :duration => 2)
Leave.create!(:employee => Employee.find_by_first_name("Jane"), :leave_type => LeaveType.first, :start_date => Date.today - 16, :end_date => Date.today - 14, :start_half => true,  :end_half => false, :duration => 2)
Leave.create!(:employee => Employee.find_by_first_name("Jane"), :leave_type => LeaveType.first, :start_date => Date.today - 12, :end_date => Date.today - 10, :start_half => false, :end_half => true,  :duration => 2)
Leave.create!(:employee => Employee.find_by_first_name("Jane"), :leave_type => LeaveType.first, :start_date => Date.today - 8,  :end_date => Date.today - 6,  :start_half => true,  :end_half => true,  :duration => 2)
Leave.create!(:employee => Employee.find_by_first_name("Jane"), :leave_type => LeaveType.first, :start_date => Date.today - 6,  :end_date => Date.today,      :start_half => true,  :end_half => true,  :duration => 2)

# schedules (useful for checkings)
Schedule.create(:service => Service.first, :morning_start=> 8.5, :morning_end => 12,  :afternoon_start => 13,  :afternoon_end => 16.5, :day => "Lundi")
Schedule.create(:service => Service.first, :morning_start=> 8.5, :morning_end => 12,  :afternoon_start => 13,  :afternoon_end => 16.5, :day => "Mardi")
Schedule.create(:service => Service.first, :morning_start=> 8.5, :morning_end => 12,  :afternoon_start => 13,  :afternoon_end => 16.5, :day => "Mercredi")
Schedule.create(:service => Service.first, :morning_start=> 8.5, :morning_end => 12,  :afternoon_start => 13,  :afternoon_end => 16.5, :day => "Jeudi")
Schedule.create(:service => Service.first, :morning_start=> 8.5, :morning_end => 12,  :afternoon_start => 13,  :afternoon_end => 16.5, :day => "Vendredi")
Schedule.create(:service => Service.first, :morning_start=> 8.5, :morning_end => 12,  :afternoon_start => nil, :afternoon_end => nil,  :day => "Samedi")
Schedule.create(:service => Service.first, :morning_start=> nil, :morning_end => nil, :afternoon_start => nil, :afternoon_end => nil,  :day => "Dimanche")

# checkings
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => nil,  :absence_period => nil,         :morning_start_comment => nil,  :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today-1, :absence_comment => nil,  :absence_period => nil,         :morning_start_comment => nil,  :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today+1, :absence_comment => nil,  :absence_period => nil,         :morning_start_comment => nil,  :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => "ok", :absence_period => "morning",   :morning_start_comment => nil,  :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => "ok", :absence_period => "afternoon", :morning_start_comment => nil,  :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => "ok", :absence_period => "whole_day", :morning_start_comment => nil,  :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => "ok", :absence_period => "morning",   :morning_start_comment => "ok", :morning_end_comment=> "ok", :afternoon_start_comment => "ok", :afternoon_end_comment => "ok")
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => nil,  :absence_period => nil,         :morning_start_comment => "ok", :morning_end_comment=> nil,  :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => nil,  :absence_period => nil,         :morning_start_comment => "ok", :morning_end_comment=> "ok", :afternoon_start_comment => nil,  :afternoon_end_comment => nil)
Checking.new(:employee => Employee.find_by_first_name("Jane"), :date=> Date.today,   :absence_comment => nil,  :absence_period => nil,         :morning_start_comment => "ok", :morning_end_comment=> "ok", :afternoon_start_comment => "ok", :afternoon_end_comment => "ok")

set_default_permissions
