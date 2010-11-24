require File.dirname(__FILE__) + '/../rh_test'

class FamilySituationTest < ActiveSupport::TestCase
  should_have_many :employees
  
  should_validate_presence_of :name
  should_validate_uniqueness_of :name
  
  should_journalize :identifier_method => :name
end
