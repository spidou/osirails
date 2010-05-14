require 'test/test_helper'

class SupplierTest < ActiveSupport::TestCase
  
  should_have_many :supplier_supplies
  should_have_many :supplies, :through => :supplier_supplies
  
end
