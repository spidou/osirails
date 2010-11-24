require 'matchers/act_as_watchable_matcher'

module ActsAsWatchable
  module Shoulda
    include Matchers
    def should_act_as_watchable
      klass = self.name.gsub(/Test$/, '').constantize
      
      matcher = act_as_watchable
      should matcher.description do
        assert_accepts(matcher, klass)
      end
    end
  end
end

class Test::Unit::TestCase #:nodoc:
  extend ActsAsWatchable::Shoulda
end
