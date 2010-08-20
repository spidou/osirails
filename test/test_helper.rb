ENV["RAILS_ENV"] = "test"

def detect_feature_from_caller(caller)
  dirs = caller.first.split("/")
  feature_name = dirs.include?("features") ? dirs[dirs.index("features")+1] : ''
end

TESTING_FEATURE = detect_feature_from_caller(caller) unless defined? TESTING_FEATURE

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'
require 'mocha'

# Plugin has_reference
require File.dirname(__FILE__) + '/../lib/plugins/has_reference/test/unit/has_reference_test'

# Plugin has_contacts
require File.dirname(__FILE__) + '/../lib/plugins/has_contacts/test/unit/has_contacts_test'
require File.dirname(__FILE__) + '/../lib/plugins/has_contacts/test/unit/has_contact_test'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Class-level method to quickly create validation tests for a bunch of actions at once.
  # For example, if you have a FooController with three actions, just add one line to foo_controller_test.rb:
  #
  #   assert_valid_markup :bar, :baz, :qux
  #
  # If you pass :but_first => :something, #something will be called at the beginning of each test case
  def assert_not_routing(path, options, defaults={}, extras={}, message=nil)
    #TODO test if this method works really
    !assert_routing(path, options, defaults, extras, message)
  end
  
  def self.assert_valid_permissions(*actions)
    #TODO faire les assertions qui permettent de tester facilement les permissions sur tous les controlleurs
  end
end

module ActionController
  module Assertions
    module ModelAssertions
      # Ensures that the passed record is valid by Active Record standards and
      # returns any error messages if it is not.
      #
      # ==== Examples
      #
      #   # assert that a newly created record is not valid
      #   model = Model.new
      #   assert_not_valid(model)
      #
      def assert_not_valid(record)
        clean_backtrace do
          assert !record.valid?, record.errors.full_messages.join("\n")
        end
      end
    end
  end
end
