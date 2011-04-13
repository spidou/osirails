require File.dirname(__FILE__) + '/../rh_test'

class EmployeeSensitiveDataTest < ActiveSupport::TestCase
  should_belong_to :family_situation
  
  should_have_one :iban
  
  should_have_many :premia
  
  should_validate_presence_of :family_situation, :with_foreign_key => :default
  
  should_allow_values_for :social_security_number, "1234567890123 45", "0123456789012 34"
  should_not_allow_values_for :social_security_number, nil, "", "1", "0123456789012 3", "012345678901 34", "123456789012345"
  
  should_allow_values_for :email, nil, "", "foo@bar.com", "foo.bar@bar.fr", "foo@bar.abcde"
  should_not_allow_values_for :email, "@foo.com", "foo@", "foo@b", "foo@bar", "foo@bar.", "foo@bar.c", "foot@bar.abcdef"
  
  
  should_journalize :attributes   => [ :birth_date, :social_security_number, :family_situation_id, :email], 
                    :subresources => [ :address, :numbers, :iban]
end
