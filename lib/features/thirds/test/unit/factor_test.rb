require File.dirname(__FILE__) + '/../thirds_test'

class FactorTest < ActiveSupport::TestCase
  should_have_many :customers
  
  should_validate_presence_of :name, :fullname
  should_validate_uniqueness_of :name
  
  should_journalize :attributes        => [ :name, :fullname ],
                    :identifier_method => :name_and_fullname
end
