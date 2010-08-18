require 'matchers/act_on_journalization_with_matcher'
require 'matchers/journalize_matcher'

module Journalization
  module Shoulda
    include Matchers
    def should_act_on_journalization_with params
      klass = self.name.gsub(/Test$/, '').constantize
      
      act_on_journalization_with_matcher = act_on_journalization_with params
      journalize_matcher = journalize :identifier_method => params
      should act_on_journalization_with_matcher.description do
        assert_accepts(act_on_journalization_with_matcher, klass)
        assert_accepts(journalize_matcher, klass)
      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend Journalization::Shoulda
end
