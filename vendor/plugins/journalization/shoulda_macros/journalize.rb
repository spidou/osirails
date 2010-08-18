require 'matchers/journalize_matcher'

module Journalization
  module Shoulda
    include Matchers
    def should_journalize params
      klass = self.name.gsub(/Test$/, '').constantize
      
      matcher = journalize params
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend Journalization::Shoulda
end
