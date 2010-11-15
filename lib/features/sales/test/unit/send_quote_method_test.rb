require File.dirname(__FILE__) + '/../sales_test'

class SendQuoteMethodTest < ActiveSupport::TestCase
  should_journalize :identifier_method => :name
end
