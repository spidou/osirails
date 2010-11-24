require File.dirname(__FILE__) + '/../rh_test'

class JobTest < ActiveSupport::TestCase
  should_have_many :employees_jobs, :dependent => :destroy
  should_have_many :employees, :through => :employees_jobs
  
  should_belong_to :service
  
  should_validate_uniqueness_of :name
  
  should_journalize :identifier_method => :name
end
